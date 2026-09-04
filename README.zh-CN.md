<div align="center">
  <img src="packages/website/public/brand/stowpaste-icon.png" width="128" height="128" alt="StowPaste 图标">

  <h1>StowPaste</h1>

  <p><strong>复制过的，不该凭空消失。</strong></p>
  <p>一个安静待在菜单栏里的 macOS 剪贴板历史工具。复制文本、图片或文件，连续按两次左 Command，随时把它们找回来。</p>

  <p>
    <img alt="StowPaste v0.1.1" src="https://img.shields.io/badge/release-v0.1.1-655DFF?style=for-the-badge">
    <img alt="macOS 14 或更高版本" src="https://img.shields.io/badge/macOS-14%2B-1C1D21?style=for-the-badge&logo=apple&logoColor=white">
    <img alt="Apple silicon 与 Intel" src="https://img.shields.io/badge/build-Universal-18B981?style=for-the-badge">
    <img alt="数据保存在本机" src="https://img.shields.io/badge/data-local--first-F05A47?style=for-the-badge">
    <img alt="Apache License 2.0" src="https://img.shields.io/badge/license-Apache--2.0-17181C?style=for-the-badge">
  </p>

  <p>
    <a href="README.zh-CN.md"><strong>简体中文</strong></a>
    ·
    <a href="README.md">English</a>
  </p>
</div>

> [!IMPORTANT]
> ### [↓ 下载 StowPaste v0.1.1（中文 DMG）](https://github.com/TseringYuu/stowpaste/releases/download/v0.1.1/StowPaste-v0.1.1-zh-CN.dmg)
> 适用于 macOS 14 或更高版本，兼容 Apple silicon 与 Intel Mac。无需账户。

<p align="center">
  <a href="https://stowpaste.aiware.store"><strong>访问官网</strong></a>
  &nbsp;·&nbsp;
  <a href="https://stowpaste.aiware.store/docs">使用指南</a>
  &nbsp;·&nbsp;
  <a href="https://stowpaste.aiware.store/privacy">隐私说明</a>
  &nbsp;·&nbsp;
  <a href="https://github.com/TseringYuu/stowpaste/releases/download/v0.1.1/StowPaste-v0.1.1-zh-CN.dmg.sha256">SHA-256</a>
</p>

![StowPaste 官网与下载界面](docs/assets/readme-hero.png)

## 三步，回到刚刚复制的内容

| 1. 复制 | 2. 呼出 | 3. 粘贴 |
| --- | --- | --- |
| 像平常一样复制文本、图片或文件。 | 连续按两次左 Command（⌘⌘），面板会出现在当前工作位置附近。 | 用键盘或鼠标选中历史项，把内容粘贴回正在使用的应用。 |

## 为高频粘贴而设计

| | 能力 | 说明 |
| --- | --- | --- |
| **⌘⌘** | 随处呼出 | 默认双击左 Command 打开面板；也可以在设置中重新录制快捷键。应用常驻菜单栏，不显示 Dock 图标。 |
| **TEXT / IMAGE / FILE** | 不把所有内容混成纯文本 | 保存文本、图片和文件历史；图片带预览并自动进入图片分组，文件保留名称与路径信息。 |
| **GROUPS** | 建立自己的秩序 | 收藏、置顶、删除、重命名历史项；创建、编辑并排序分组，也可以把内容直接拖到分组标签。 |
| **PANEL** | 适应当前工作区 | 支持键盘导航和鼠标操作；面板可以移动、缩放，或钉在屏幕上保持显示。 |
| **THEMES** | 看起来也属于你 | 跟随系统浅色或深色外观，也可以在本机生成并保存自定义配色主题。 |
| **RETENTION** | 留多久，由你决定 | 设置普通历史的保留期限；收藏、置顶和自定义分组中的内容不会被定期清理。 |

## 安装

1. 下载并打开 [StowPaste v0.1.1 中文 DMG](https://github.com/TseringYuu/stowpaste/releases/download/v0.1.1/StowPaste-v0.1.1-zh-CN.dmg)。
2. 将 `StowPaste.app` 拖到磁盘映像中的「应用程序」快捷方式上。
3. 从「应用程序」启动 StowPaste；macOS 可能提示无法验证开发者。
4. 打开「系统设置 → 隐私与安全性」，向下滚动到「安全性」，为 StowPaste 选择「仍要打开」，并按提示确认身份。
5. 按提示授予「辅助功能」权限；如果授权页没有自动打开，请前往「系统设置 → 隐私与安全性 → 辅助功能」并启用 StowPaste。

辅助功能权限用于监听全局快捷键、恢复原来的输入焦点，以及把选中的内容粘贴回当前应用。

> [!NOTE]
> `v0.1.1` 是不使用付费 Apple Developer 账户的独立开源构建。应用本体使用不包含个人身份的 ad-hoc 签名，应用与磁盘映像未经 Developer ID 签名或 Apple 公证。请先检查源码与 SHA-256，再为 StowPaste 创建上述单应用例外；不要全局关闭 Gatekeeper。
>
> 更新时请先退出正在运行的旧版本，再覆盖应用。如果「系统设置 → 隐私与安全性 → 辅助功能」里已经启用 StowPaste，但应用仍提示未授权，请删除旧的 StowPaste 条目，点 `+` 重新加入 `/Applications/StowPaste.app`，然后退出并重新打开 StowPaste。

<details>
<summary><strong>校验磁盘映像</strong></summary>

下载官方校验文件，或在终端执行：

```bash
shasum -a 256 StowPaste-v0.1.1-zh-CN.dmg
```

预期 SHA-256：

```text
fa079ae72de43632e58c2d85c671d68ffaf5ffcbd0647f41b0486c2a085150c2
```

</details>

技术用户也可以检查源码并在本机构建 StowPaste。所需工具链和已验证命令见[开发文档](docs/DEVELOPMENT.md)。

## 使用

### 打开与粘贴

- 默认连续按两次左 Command（⌘⌘）打开粘贴面板。
- 也可以点击菜单栏图标，选择「显示主面板」。
- 面板优先靠近当前输入光标；没有输入焦点时，会根据鼠标位置选择合适的位置。
- 点击历史项即可粘贴。面板打开时再次按下快捷键，可快速粘贴当前剪贴板内容。

### 整理历史

- 收藏常用内容，或将重要内容置顶。
- 重命名难以辨认的历史项。
- 新建自定义分组，编辑名称与图标，并调整分组顺序。
- 将历史项拖到上方分组标签完成归类。
- 删除不再需要的内容；当前剪贴板对应的历史项会受到保护，避免误删。

### 调整工作方式

- 拖动与缩放面板，使它适合当前屏幕和窗口布局。
- 将面板钉在屏幕上，连续处理多次粘贴。
- 选择系统、浅色、深色或本地自定义主题。
- 设置历史保留期限，并按需启用开机启动。

## 本地数据与隐私

- 剪贴板历史、图片和设置保存在当前 Mac 的 Application Support 目录。
- 当前版本不需要账户，也不会把剪贴板内容上传到外部服务。
- 自定义主题在本机生成，主题描述不会发送到外部服务。
- 日志和应用状态可能包含剪贴板相关信息，请不要公开分享未经检查的文件。

完整说明见 [StowPaste 隐私页面](https://stowpaste.aiware.store/privacy)。

## 仓库结构

```text
packages/app/         SwiftUI / AppKit macOS 应用
packages/website/     官网、使用指南与下载接口
Scripts/              构建、打包和验证脚本
docs/                 维护者文档与 README 资源
```

常用开发命令：

```bash
npm install
swift build --package-path packages/app
npm run website:build
./Scripts/verify_all.sh
```

维护说明见 [开发文档](docs/DEVELOPMENT.md)、[安全策略](SECURITY.md) 与 [更新日志](CHANGELOG.md)。

## 开源许可

StowPaste 以 [Apache License 2.0](LICENSE) 开源。你可以使用、修改、分发和商业使用本项目，但必须保留适用的版权、许可证和 NOTICE 声明。第三方组件仍受其各自许可证约束，详见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

参与开发前请阅读 [贡献指南](CONTRIBUTING.md)。
