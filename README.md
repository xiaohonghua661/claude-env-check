# Windows 环境伪装一键工具（Disguise Tool）

> 单文件 bat，双击即用。内置**本地网页控制台**（浏览器操作界面），用于 Windows 环境伪装与检测。

## 功能

| 功能 | 说明 |
|---|---|
| 一键切换 | 英文(en-US) + 纽约时区 ⇄ 中文(zh-CN) + 北京（含 Chrome 语言、系统区域、地理位置） |
| 全面检测 | 系统 / 浏览器 / 网络 分层证据检测，实测浏览器指纹（navigator.language、Intl 时区） |
| 铁证报告 | 每次检测自动生成带时间戳的检测报告（同目录「铁证报告」文件夹） |
| WebRTC 防泄露 | 自动写入 Chrome 策略 WebRTCIPHandlingPolicy=3，浏览器不再泄露真实公网 IP |
| Chrome 语言修复 | 修改所有配置文件的首选语言（自动备份 .bak_*） |
| Claude Code 检查 | 检查 Claude Code 客户端环境的时区/区域/代理/WebRTC 指纹 |
| 本地网页 UI | 随机端口、仅监听 127.0.0.1，不对外暴露 |

## 使用方法

1. 下载 `伪装环境一键工具.bat`，双击运行
2. 自动打开浏览器网页控制台（本地服务）
3. 点按钮操作：全面检测 / 修复为英文+纽约 / 切回中文+北京 / Claude客户端检查 / 打开铁证报告

> 检测不需要管理员；修复/切回会自动请求 UAC 提权。

## 环境要求

- Windows 10 / 11
- 需要 Chrome（用于浏览器指纹检测）或 Edge（自动回退）
- 修复功能需要管理员权限（自动弹 UAC）

## 注意事项

- 脚本为 **UTF-8 编码**（内部 chcp 65001），请勿用 GBK 编辑器改写
- 修复系统区域/显示语言后需**重启电脑**完全生效
- Chrome 语言修改需**完全退出 Chrome** 后重开生效
- 出口 IP 归属存在数据库分歧属正常现象（不同 IP 库对同一 IP 判定可能不同）

## 原理

- 系统层：时区 tzutil、区域 Set-Culture、显示语言 Set-WinUILanguageOverride、系统区域 Set-WinSystemLocale、地理位置 Set-WinHomeLocation
- 浏览器层：Chrome Preferences 的 selected_languages / accept_languages
- 网络层：DNS、WebRTC 策略、出口 IP 多库对比
- 安全：仅本机回环 HTTP 服务，无外部服务器参与
