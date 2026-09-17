// Workaround for kotlin-lsp's Android import (Kotlin/kotlin-lsp#225), mirroring layer 1 of PR #233.
// KSP registers generated sources on the androidTest/unitTest components too. kotlin-lsp's
// 'prepareKotlinIdeaImport' only declares the main variants' sources as inputs, so the test
// components' KSP tasks never run and reading their sources throws, emptying the whole import.
// Declare the nested components' sources as inputs as well, so Gradle runs those tasks first.
// Tests stay visible to the language server. Ordinary builds, Android Studio and CI are untouched.
//
// Kotlin, not Groovy: Gradle 9.1's Groovy compiler rejects JDK 26 class files. AGP classes
// aren't on an init script's classpath, hence the dynamic calls.
//
// Install: ~/.gradle/init.d/kotlin-lsp-android-ksp-inputs.init.gradle.kts
// Remove once #233 ships.

val isKotlinLspImport = gradle.startParameter.allInitScripts.any { it.name.startsWith("lsp-gradle-") } ||
    System.getProperties().keys.any { it.toString().startsWith("com.jetbrains.ls.imports.gradle") }

if (isKotlinLspImport) {
    gradle.beforeProject {
        val project = this
        plugins.withId("com.android.base") {
            val components = project.extensions.getByName("androidComponents")
            val all = components.withGroovyBuilder { "selector"() }!!.withGroovyBuilder { "all"() }!!
            components.withGroovyBuilder {
                "onVariants"(all, Action<Any> {
                    val nested = withGroovyBuilder { getProperty("nestedComponents") } as? Iterable<*> ?: emptyList<Any>()
                    project.tasks.matching { it.name == "prepareKotlinIdeaImport" }.configureEach {
                        val task = this
                        for (component in nested) {
                            val sources = component!!.withGroovyBuilder { getProperty("sources") } ?: continue
                            for (kind in listOf("kotlin", "java", "resources")) {
                                val dirs = sources.withGroovyBuilder { getProperty(kind) } ?: continue
                                task.inputs.files(dirs.withGroovyBuilder { getProperty("all") })
                            }
                        }
                    }
                })
            }
        }
    }
    gradle.rootProject { logger.lifecycle("[kotlin-lsp workaround] test component sources wired into prepareKotlinIdeaImport") }
}
