# Ghosten Player — Android 6 (API 23) 兼容性修复

基于 [GhostenEditor/Ghosten-Player](https://github.com/GhostenEditor/Ghosten-Player) v2.4.7 修改，
用于修复 **Android 6.0 电视上点「添加目录」的 `+` 按钮后应用直接退出**的问题。

## 问题原因

TV 端「电视剧/电影目录设置」→ `+` → 打开 `DriverFilePicker`（文件选择页），
该页在构建时立刻调用 `FilePicker.externalUsbStorages()`，其原生实现为：

```kotlin
// packages/file_picker/android/src/main/kotlin/com/ghosten/file_picker/FilePickerPlugin.kt
private fun getUniversalUSBPath(): List<HashMap<String, String>> {
    val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as StorageManager
    val storageVolumes: List<StorageVolume> = storageManager.storageVolumes  // ← API 24+
```

`StorageManager` 及 `getStorageVolumes()` 自 **Android 7.0 (API 24)** 才存在。
在 **Android 6.0 (API 23)** 上会抛 `TypeCastException` / `NoSuchMethodError`，
页面初始化即失败，表现为「一点 `+` 就退回桌面」。

## 修改内容

1. **`packages/file_picker/android/.../FilePickerPlugin.kt`**
   `getUniversalUSBPath()` 增加版本保护：API < 24 直接返回空列表，
   并对 `getSystemService` 与 `storageVolumes` 取值加了 try/catch 兜底。

2. **`app/pubspec.yaml`**
   5 个 git 依赖（`api` / `bluetooth` / `file_picker` / `logger` / `video_player`）
   改为本地路径依赖，指向本仓库内的 `packages/`，这样补丁能生效、CI 也无需拉外网。

   原写法：
   ```yaml
   file_picker:
     git:
       url: https://github.com/GhostenEditor/Ghosten-Player-flutter-packages.git
       path: file_picker
       ref: v0.0.10
   ```
   改后：
   ```yaml
   file_picker:
     path: ../packages/file_picker
   ```

## 目录结构

```
.
├── .github/workflows/build-tv.yml   # GitHub Actions 构建配置
├── app/                             # Ghosten-Player 主工程
└── packages/                        # 作者依赖包（含已修复的 file_picker）
```

## 构建（GitHub Actions，本地无需装 Flutter/Android SDK）

推送到 GitHub 后自动触发，或在 Actions 页面手动 `Run workflow`。

- Flutter：**3.32.8**（与原项目 CI 一致）
- JDK：17
- 命令：`flutter build apk --release --split-per-abi --flavor tv -t lib/main_tv.dart`

产物在 Actions 的 **Artifacts → ghosten-tv-apk** 中下载。
其中 `app-armeabi-v7a-tv-release.apk` 适用于 32 位 Android TV（本修复的目标设备）。

## 安装

```bash
adb install -r app-armeabi-v7a-tv-release.apk
```

## 说明

- 签名使用 CI 中临时生成的 keystore，与官方版本不同。
  如需覆盖安装官方版，请先卸载官方版本（会丢失应用内数据与账号登录），
  或把 `applicationId` 改成别的（如 `com.ghosten.player.fixed`）以便共存。
- 本仓库仅用于修复兼容性问题，版权归原作者所有。
