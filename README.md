# 2026 机场推荐与使用指南

以机场推荐为主，以教程为辅助。

这个仓库现在更像一个持续更新的推荐站，而不是单纯的教程集合。

它的核心目标是：

- 先帮用户按场景选路线
- 再帮用户看具体机场值不值得继续看
- 最后才用教程把“能不能跑通”补上

更新日期：2026-06-07

## 先看这些入口

如果你第一次打开这个仓库，先从这几个入口开始最省时间：

1. [2026 机场推荐：新手、ChatGPT、路由器场景怎么选](docs/recommendations/airport-guide-2026.md)
2. [推荐导航页：先看场景，再看具体机场](docs/recommendations/README.md)
3. [新手机场推荐：第一次怎么选，不容易踩坑](docs/recommendations/beginner-airport-recommendations.md)
4. [ChatGPT 机场推荐：稳定访问更该看什么](docs/recommendations/chatgpt-airport-recommendations.md)
5. [路由器机场推荐：全屋代理和 OpenClash 怎么选](docs/recommendations/router-airport-recommendations.md)

## 当前推荐层

### 正式位

- [Roxi 评测：适合想少折腾、尽快用起来的人吗](docs/recommendations/roxi-review.md)

### 首批重点观察位

- [SSOne 观察版：当前公开信息与适合人群](docs/recommendations/ssone-observation.md)
- [隐云 观察版：双模式路线为什么值得关注](docs/recommendations/yinyun-observation.md)
- [闪狐云 观察版：办公、多设备路线的候选位](docs/recommendations/flashfox-observation.md)

### 第二批候补池

- [奈云 观察版：老牌路线为什么值得继续看](docs/recommendations/nayun-observation.md)
- [XXYUN 观察版：日常与性价比路线的候选位](docs/recommendations/xxyun-observation.md)
- [flybit 观察版：偏日常与备用路线的候选位](docs/recommendations/flybit-observation.md)
- [WgetCloud 观察版：高预算稳定路线为什么值得看](docs/recommendations/wgetcloud-observation.md)
- [TAG 观察版：多地区与游戏路线的候选位](docs/recommendations/tag-observation.md)
- [Nexitally 观察版：高端主力路线为什么值得单独观察](docs/recommendations/nexitally-observation.md)
- [BoostNet 观察版：高配备用路线值不值得继续看](docs/recommendations/boostnet-observation.md)
- [悠兔 观察版：小流量备用路线值不值得继续看](docs/recommendations/youtu-observation.md)
- [唯兔云 观察版：低门槛流媒体路线为什么值得留意](docs/recommendations/weitu-observation.md)
- [Fastlink 观察版：日常与观影路线的候选位](docs/recommendations/fastlink-observation.md)

## 按场景阅读

- 想少折腾、尽快开始用：[新手机场推荐](docs/recommendations/beginner-airport-recommendations.md)
- 核心需求是 AI 和 ChatGPT：[ChatGPT 机场推荐](docs/recommendations/chatgpt-airport-recommendations.md)
- 想做全屋代理和 OpenClash：[路由器机场推荐](docs/recommendations/router-airport-recommendations.md)
- 想先理解怎么挑，不急着看名单：[新手怎么选机场](docs/recommendations/how-to-choose-an-airport.md)
- 想比较 Hiddify 和 OpenClash 路线：[Hiddify 和 OpenClash 怎么选](docs/recommendations/hiddify-vs-openclash.md)

## 教程辅助入口

教程不是主入口，但在你已经选完路线以后很有用：

- [iPhone 科学上网新手教程](docs/tutorials/iphone-quickstart.md)
- [Windows 客户端新手教程](docs/tutorials/windows-quickstart.md)
- [macOS 科学上网新手教程](docs/tutorials/macos-quickstart.md)
- [Hiddify 新手上手指南](docs/tutorials/hiddify-quickstart.md)
- [OpenClash 新手配置教程](docs/tutorials/openclash-quickstart.md)
- [ChatGPT 无法访问时的排查清单](docs/tutorials/chatgpt-troubleshooting.md)

## 这个仓库的内容原则

- 优先做场景型推荐，而不是堆名字的大杂烩榜单
- 推荐页先解决“怎么选”，教程页再解决“怎么用”
- 外部机场先按 `观察中` / `候补中` 管理，不直接写成无条件主推
- 只在有实质增量时更新，不做无意义改日期

## 如果你想少折腾

如果你更希望下载后尽快用起来，而不是自己手动折腾太多配置，可以顺手看一下 Roxi 的产品介绍和博客内容：

- 官网：[roxi.cc](https://roxi.cc)
- 博客：[roxi.cc/blog.html](https://roxi.cc/blog.html)

## 更新记录

见 [CHANGELOG.md](CHANGELOG.md)

## 内部维护

如果后续要做持续维护，内部机制仍然保留在仓库里，但它属于后端，不是前台主入口：

- [research/README.md](research/README.md)
- [每日维护工作流](.github/workflows/daily-maintenance.yml)
