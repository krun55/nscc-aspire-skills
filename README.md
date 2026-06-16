# ASPIRE 2A Skills

English | [中文](#中文)

A small public skill pack for working with NSCC Singapore ASPIRE 2A.
It works with both Codex and Claude Code (cc), and currently contains two skills:

- `nscc-aspire2a-ssh`: configure SSH aliases, private-key placement, VPN checks, and basic ASPIRE 2A login validation.
- `aspire-hf-download`: download large Hugging Face models or datasets reliably on ASPIRE 2A through PBS jobs, `huggingface_hub.snapshot_download`, Xet support, and scratch storage.

These skills are written as standard `SKILL.md` directories. Both Codex and Claude Code discover them from the `SKILL.md` frontmatter, so you can install the whole pack or copy only the skill you need.

## Install

Clone this repository, then run:

```bash
bash install.sh
```

By default the installer copies both skill directories into both agents' skill homes:

```text
${CODEX_HOME:-$HOME/.codex}/skills          # Codex
${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills  # Claude Code
```

To install for one agent only:

```bash
AGENT=codex  bash install.sh   # Codex only
AGENT=claude bash install.sh   # Claude Code only
```

To install manually (pick the target that matches your agent):

```bash
# Codex
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
cp -R skills/aspire-hf-download "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R skills/nscc-aspire2a-ssh "${CODEX_HOME:-$HOME/.codex}/skills/"

# Claude Code
mkdir -p "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
cp -R skills/aspire-hf-download "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/"
cp -R skills/nscc-aspire2a-ssh "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/"
```

Restart Codex / Claude Code after installing if the new skills are not discovered immediately.

## Usage

Ask your agent (Codex or Claude Code) for the workflow you need:

```text
Set up my NSCC ASPIRE 2A SSH access.
```

```text
Create a PBS job to download a gated Hugging Face model to ASPIRE scratch.
```

The SSH skill includes a setup helper:

```bash
bash skills/nscc-aspire2a-ssh/scripts/setup_nscc_aspire2a_ssh.sh
```

The Hugging Face download skill includes a PBS template that keeps large downloads off the login node and writes model or dataset files under `/scratch/users/nus/$USER/...`.

## Security Notes

- Do not commit private SSH keys, Hugging Face tokens, PBS logs containing secrets, or real account-specific paths.
- The SSH setup script stores private keys only under the local `~/.ssh` directory and validates them before installing.
- The Hugging Face PBS template prints token existence and token length only; it should not print token values.
- Public examples use placeholders such as `e1538xxx`. Replace them with your own NSCC username and project/account string.

## Repository Layout

```text
skills/
  aspire-hf-download/
    SKILL.md
  nscc-aspire2a-ssh/
    SKILL.md
    agents/openai.yaml
    references/classmate-quickstart.md
    scripts/setup_nscc_aspire2a_ssh.sh
```

## License

MIT License. See [LICENSE](LICENSE).

---

# 中文

这是一个面向 NSCC Singapore ASPIRE 2A 的 skill 小合集，公开发布，方便复用和分享。
同时支持 Codex 和 Claude Code（cc），当前包含两个 skill：

- `nscc-aspire2a-ssh`：配置 ASPIRE 2A SSH 访问，包括 SSH alias、私钥落盘、NUS VPN 检查、登录验证和基础排障。
- `aspire-hf-download`：在 ASPIRE 2A 上稳定下载 Hugging Face 模型或数据集，使用 PBS 作业、`huggingface_hub.snapshot_download`、Xet 支持和 scratch 存储。

这些 skill 都是标准的 `SKILL.md` 目录，Codex 和 Claude Code 都会从 `SKILL.md` frontmatter 自动识别。可以整包安装，也可以只复制需要的一个 skill。

## 安装

克隆仓库后运行：

```bash
bash install.sh
```

默认会同时安装到两个 agent 的 skill 目录：

```text
${CODEX_HOME:-$HOME/.codex}/skills          # Codex
${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills  # Claude Code
```

只想装到其中一个：

```bash
AGENT=codex  bash install.sh   # 只装 Codex
AGENT=claude bash install.sh   # 只装 Claude Code
```

也可以手动安装（按自己用的 agent 选择目标）：

```bash
# Codex
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
cp -R skills/aspire-hf-download "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R skills/nscc-aspire2a-ssh "${CODEX_HOME:-$HOME/.codex}/skills/"

# Claude Code
mkdir -p "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
cp -R skills/aspire-hf-download "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/"
cp -R skills/nscc-aspire2a-ssh "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/"
```

如果 Codex / Claude Code 没有马上识别新 skill，重启即可。

## 使用方式

直接告诉你的 agent（Codex 或 Claude Code）你要做的事情，例如：

```text
帮我配置 NSCC ASPIRE 2A 的 SSH 登录。
```

```text
帮我写一个 PBS 作业，把 Hugging Face 上的 gated 模型下载到 ASPIRE scratch。
```

SSH skill 自带配置脚本：

```bash
bash skills/nscc-aspire2a-ssh/scripts/setup_nscc_aspire2a_ssh.sh
```

Hugging Face 下载 skill 自带 PBS 模板，重点是避免在 login node 前台跑大文件下载，并把模型或数据集放到 `/scratch/users/nus/$USER/...`。

## 安全提示

- 不要把 SSH 私钥、Hugging Face token、包含敏感信息的 PBS 日志、真实账号路径提交到公开仓库。
- SSH 配置脚本只会把私钥写入本机 `~/.ssh`，并在安装前做 key 校验。
- Hugging Face PBS 模板只打印 token 是否存在和长度，不打印 token 内容。
- 公开示例统一使用 `e1538xxx` 这类占位符；实际使用时替换成自己的 NSCC 用户名和项目/account 字符串。

## 目录结构

```text
skills/
  aspire-hf-download/
    SKILL.md
  nscc-aspire2a-ssh/
    SKILL.md
    agents/openai.yaml
    references/classmate-quickstart.md
    scripts/setup_nscc_aspire2a_ssh.sh
```

## 许可

MIT License，见 [LICENSE](LICENSE)。
