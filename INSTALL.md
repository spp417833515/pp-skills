# 安装 pp-skills(让 AI 自动装 · Claude + Codex 通用)

> 对你的 AI(Claude Code 或 Codex)说一句:
> **"按这个仓库的 INSTALL.md 安装 pp-skills"**
> AI 读完本文件即可自动完成安装。

## 这是什么

6 个串联技能 = 一条「澄清 → 方案 → 执行 → 审查 → 同步 → 归档」的开发流水线。
每阶段人点头才进下一阶段,产物沉淀进 ppwiki 知识库。详见 [README.md](README.md)。

## AI 自动安装步骤(Claude 或 Codex 照做)

1. **识别运行时**
   - 存在 `~/.claude/` → 装到 `~/.claude/skills/`(Claude Code)
   - 存在 `~/.codex/`  → 装到 `~/.codex/skills/`(Codex)
   - 两个都在 → 两个都装

2. **拷技能**:把本仓库 `skills/pp-*/` 整目录拷到对应 `~/.<tool>/skills/`
   (已存在同名先删再拷,保证是最新版)

3. **清旧版**:删除 `~/.<tool>/skills/` 下无前缀的旧版 `clarify-v2` `plan-v2` `archive-v2`(若有)
   —— 单一信源,避免新旧两套混淆

4. **验依赖**:确认 ppwiki MCP 已配置
   - Claude:项目 `.mcp.json` 或全局有 `pp_wiki` / `ppwiki`
   - Codex:`~/.codex/config.toml` 有 `[mcp_servers.pp_wiki]`
   - 未配 → 见 [ppwiki-setup.md](ppwiki-setup.md)(技能没它跑不起来)

5. **重启**:新技能通常热加载;若 `/` 菜单没出现,重启一次工具

6. **报告**:列出已装的 6 技能 + ppwiki 状态

## 一键脚本(等价于上面)

```bash
bash install.sh
```

脚本会:检测 Claude/Codex → 拷 6 技能 → 清理旧 v1 → 提示 ppwiki 状态。

## 装完怎么用

对 AI 输入 `/pp-clarify-v2 <一句话需求>`,按提示一路 `A` 到 `/pp-archive-v2`。

> 6 技能默认 `disable-model-invocation`(Claude 侧):只你手动喊,AI 不自动触发,守住「人点头」闸门。
> Codex 侧暂不认该字段,技能可被 AI 触发——若要 Codex 也只手动,删该行或改用 Codex 的等价控制。
