// THÊM ĐOẠN BUILDSCRIPT NÀY LÊN TRÊN CÙNG
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Báo cho dự án biết có sự tồn tại của thư viện Google Services
        classpath("com.google.gms:google-services:4.4.1")
    }
}

// BÊN DƯỚI LÀ CODE CŨ CỦA BẠN (Giữ nguyên)
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}