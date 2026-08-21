# GCP Egress Guard

独立的 Google Cloud Standard Tier 出站流量监控和入站保护工具，适合只有一台免费层级 VM 的场景。

它直接读取指定网卡的 TX 字节数，不依赖 vnStat、CDN IP 列表或 `gcp_free` 项目。

## 功能

- 每 5 分钟统计网卡出站流量
- 按 Google Cloud 月度计量边界累计
- 默认 150 GiB 企业微信告警
- 默认 180 GiB 后关闭除 SSH 外的入站连接
- 新计量月自动解除入站保护
- 北京时间每月 15、20、25 日 10:00 发送一次图文摘要
- 企业微信应用消息支持公网 IP、进度条、当前流量和入站状态
- systemd timer 开机自启
- 状态文件原子替换，降低断电损坏风险

## 安装

需要 root、systemd、bash、curl、python3、iptables。

```bash
git clone https://github.com/lgpay/gcp-egress-guard.git
cd gcp-egress-guard
sudo bash scripts/install.sh
sudoedit /etc/gcp-egress-guard/config
```

安装脚本不会覆盖已有的 `/etc/gcp-egress-guard/config`。

## 企业微信应用配置

在 `/etc/gcp-egress-guard/config` 填写：

```bash
QYWX_CORP_ID='企业ID'
QYWX_CORP_SECRET='应用Secret'
QYWX_AGENT_ID='应用AgentId'
QYWX_TOUSER='@all'
QYWX_PIC_URL='https://example.com/cover.png'
SERVER_NAME='我的免费主机'
```

配置文件包含 Secret，权限应保持为 `0600`，不要提交到 Git。

测试通知：

```bash
sudo /usr/local/sbin/gcp-egress-guard --test-notification
```

## 阈值和计量月份

```bash
WARN_GIB=150
LIMIT_GIB=180
QUOTA_GIB=200
GCP_BILLING_TZ='America/Los_Angeles'
```

`QUOTA_GIB` 只用于进度条和消息展示；`LIMIT_GIB` 决定何时触发入站保护。

本地网卡统计是 Google Cloud 计费流量的近似保护指标，最终费用以 Cloud Billing 为准。脚本无法回溯安装前的流量，也无法恢复服务器停机期间的历史明细。

## 查看状态

```bash
systemctl status gcp-egress-guard.timer
cat /var/lib/gcp-egress-guard/state
journalctl -t gcp-egress-guard -n 30
iptables -S GCP_EGRESS_GUARD
```

## 卸载

```bash
sudo bash scripts/uninstall.sh
```

卸载会删除服务、定时器和执行文件，但保留配置与统计状态，便于恢复。

## 安全说明

保护动作只创建并管理 `GCP_EGRESS_GUARD` 独立链，不执行 `iptables -F`，不会清空其他防火墙规则。它默认保留 TCP/22 和 loopback；如果 SSH 使用非 22 端口，请修改脚本中的规则后再启用 `ACTION=block`。
