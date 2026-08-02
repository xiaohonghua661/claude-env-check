# 更新日志（Changelog）

## v1.1.0 - 2026-08-02

**修复命令行中文乱码 + 修复提权脚本 bug**

### 新增
- 「修复命令行中文」按钮：一键把控制台默认代码页设为 65001（UTF-8）+ 中文字体 NSimSun，新开 cmd / PowerShell 可正常输入显示中文（不影响 en-US 伪装）
- 全面检测新增「命令行中文」检查项（代码页 + 字体）
- 「修复为英文+纽约」自动同步命令行中文修复

### 修复
- 修复提权修复脚本中注册表路径丢失反斜杠的 bug（HKLM:\SOFTWARE\Policies\Google\Chrome、Chrome User Data 等）

### 验收
- 黑盒验收：PASS（首页 / /api/fixcmd / /api/claude / /api/check 全部 200，命令行中文检查项 PASS）

## v1.0.0 - 2026-08-02

**首个公开版本（单文件网页版）**

### 新增
- 本地网页控制台 UI（浏览器操作界面，替代命令行菜单）
- 全面检测：系统/浏览器/网络分层证据，含 headless Chrome 实测浏览器指纹
- 铁证报告：检测结果自动存档（时间戳 txt）
- WebRTC 防泄露策略（WebRTCIPHandlingPolicy=disable_non_proxied_udp）
- Claude Code 客户端环境检查（时区/区域/代理/WebRTC 策略）
- 一键修复为 英文+纽约 / 一键切回 中文+北京（含 Chrome 语言、WebRTC 策略）

### 修复
- 修复管理员权限下浏览器指纹无法获取的问题（检测自动降权 / 明确提示）
- 修复 headless Chrome 输出捕获竞态（重试读取 + 临时文件加载）
- DNS 改为 1.1.1.1/8.8.8.8（去除中国公共 DNS 指纹）

### 验收
- 黑盒验收测试：PASS（首页 UI / /api/check / /api/claude / 提权修复逻辑复测复现）