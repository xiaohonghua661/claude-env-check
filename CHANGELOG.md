# 更新日志（Changelog）

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
