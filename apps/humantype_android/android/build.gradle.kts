allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val fixLegacyPlugin = Action<Project> {
        if (hasProperty("android")) {
            val android = extensions.getByName("android")
            val manifestFile = file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                try {
                    val content = manifestFile.readText()
                    val packageRegex = Regex("""package\s*=\s*"([^"]*)"""")
                    val match = packageRegex.find(content)
                    
                    if (match != null) {
                        val originalPackage = match.groupValues[1]
                        
                        // Set namespace if not already set
                        val getNamespace = android.javaClass.getMethod("getNamespace")
                        val currentNamespace = getNamespace.invoke(android)
                        if (currentNamespace == null) {
                            val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                            setNamespace.invoke(android, originalPackage)
                        }
                        
                        // Remove package attribute from manifest to satisfy AGP 8.0+
                        val updatedContent = content.replace(packageRegex, "")
                        if (content != updatedContent) {
                            manifestFile.writeText(updatedContent)
                            logger.quiet("Auto-fixed legacy manifest for: ${project.name} ($originalPackage)")
                        }
                    }
                } catch (e: Exception) {
                    logger.warn("Failed to auto-fix manifest for ${project.name}: ${e.message}")
                }
            } else {
                // Fallback for projects without standard manifest location
                try {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val currentNamespace = getNamespace.invoke(android)
                    if (currentNamespace == null) {
                        val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                        setNamespace.invoke(android, "com.humantype.${name.replace("-", "_")}")
                    }
                } catch (e: Exception) {}
            }
        }
    }

    if (state.executed) {
        fixLegacyPlugin.execute(this)
    } else {
        afterEvaluate {
            fixLegacyPlugin.execute(this)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
