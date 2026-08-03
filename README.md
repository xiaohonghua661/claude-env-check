# Claude 环境检测（Claude Env Check）

> 单文件 bat，双击即用。内置**本地网页控制台**，用于 Windows 环境伪装与检测（含 Claude Code 客户端环境检查）。


## 使用者声明

维护者是**在美国生活的中国用户**。本仓库的环境配置（英文 + 纽约时区 + 美国地理位置）对应其在美国的日常使用环境。

第三方风险检测（[fuck-claude.com/zh/](https://fuck-claude.com/zh/)）实测：**20/100（低风险）**。系统时区、浏览器语言、Intl 区域、时区偏移、浏览器与设备品牌六项信号已全部归零；剩余 18 分（Windows 内置中文字体）与 2 分（Windows Emoji 渲染）为所有 Windows 机器的结构性信号，真实美国英文版 Windows 得分相同，是该网站的理论下限。
## 功能

| 功能 | 说明 |
|---|---|
| 一键切换 | 英文(en-US) + 纽约时区 ⇄ 中文(zh-CN) + 北京（含 Chrome 语言、系统区域、地理位置；**保留现有输入法，不删除搜狗**） |
| 全面检测 | 系统 / 浏览器 / 网络 分层证据检测，实测浏览器指纹（navigator.language、Intl 时区） |
| 铁证报告 | 每次检测自动生成带时间戳的检测报告（同目录「铁证报告」文件夹） |
| WebRTC 防泄露 | 自动写入 Chrome 策略 WebRTCIPHandlingPolicy=3，浏览器不再泄露真实公网 IP |
| Chrome 语言修复 | 修改所有配置文件的首选语言（自动备份 .bak_*） |
| 命令行中文修复 | 一键把控制台默认代码页设为 65001(UTF-8) + 中文字体 NSimSun，新开 cmd/PowerShell 正常显示中文（不影响伪装） |
| 微软拼音开关 | 一键开启/关闭 zh-Hans-CN 中的微软拼音（搜狗输入法始终保留，无需管理员权限） |
| Claude Code 检查 | 检查 Claude Code 客户端环境的时区/区域/代理/WebRTC 指纹 |
| 本地网页 UI | 随机端口、仅监听 127.0.0.1，不对外暴露 |

## 使用方法

1. 下载 `伪装环境一键工具.bat`，双击运行
2. 自动打开浏览器网页控制台（本地服务）
3. 点按钮操作：全面检测 / 修复为英文+纽约 / 切回中文+北京 / 微软拼音开关 / 修复命令行中文 / Claude客户端检查 / 打开铁证报告

> 检测不需要管理员；修复/切回会自动请求 UAC 提权；修复命令行中文与微软拼音开关无需管理员。

## 环境要求

- Windows 10 / 11
- 需要 Chrome（用于浏览器指纹检测）或 Edge（自动回退）
- 修复功能需要管理员权限（自动弹 UAC）

## 注意事项

- 脚本为 **UTF-8 编码**（内部 chcp 65001），请勿用 GBK 编辑器改写
- 修复系统区域/显示语言后需**重启电脑**完全生效
- Chrome 语言修改需**完全退出 Chrome** 后重开生效
- 命令行中文修复只对新开的 cmd/PowerShell 窗口生效（需关掉重开）
- 切换英文/中文时**保留现有输入法**（搜狗 + 微软拼音不会被删除）；默认输入法固定为美国键盘
- 出口 IP 归属存在数据库分歧属正常现象（不同 IP 库对同一 IP 判定可能不同）

## 原理

- 系统层：时区 tzutil、区域 Set-Culture、显示语言 Set-WinUILanguageOverride、系统区域 Set-WinSystemLocale、地理位置 Set-WinHomeLocation
- 语言层：语言列表**保留式重排**（只调首位，不重建），默认输入法 InputMethodOverride=0409:00000409
- 浏览器层：Chrome Preferences 的 selected_languages / accept_languages
- 控制台层：HKCU\Console 代码页 65001 + 字体 NSimSun（让命令行可显示中文）
- 网络层：DNS、WebRTC 策略、出口 IP 多库对比
- 安全：仅本机回环 HTTP 服务，无外部服务器参与