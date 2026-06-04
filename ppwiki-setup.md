# 依赖:ppwiki MCP

pp-skills 全程读写 ppwiki(澄清条目 / wiki 知识库 / task 阶段状态机 / review / decision)。
**没有 ppwiki MCP,这 6 个技能跑不起来。**

## 它提供什么

一个 MCP 工具 `ppwiki`,8 个模块:`system / task / review / state / skill / wiki / clarify / decision`。
调用格式 `ppwiki('模块 --动作', {...})`,op 全集见 `ppwiki('system --ops')`,
参数 schema 查 `ppwiki('system --help', {module:'<模块>'})`。

## 配置

> 下面是把 ppwiki server 挂成 MCP 的形态;`command`/包名以 ppwiki 项目自身 README 为准。

### Claude Code — 项目 `.mcp.json`(或全局)

```json
{
  "mcpServers": {
    "ppwiki": {
      "command": "python",
      "args": ["-m", "pp_wiki.mcp.server", "--project-root", "<你的项目根绝对路径>"]
    }
  }
}
```

### Codex — `~/.codex/config.toml`

```toml
[mcp_servers.pp_wiki]
command = "python"
args = ["-m", "pp_wiki.mcp.server", "--project-root", "<你的项目根绝对路径>"]
```

## 验证

装好后,在 AI 里跑一次:

```
ppwiki('system --health')
```

返回 `{ok:true, ...}` 即通。再 `ppwiki('system --ops')` 能看到 83 个 op。

## 数据落在哪

- 澄清 → `ppwiki clarify` 条目 + `.pp/wiki/澄清/`
- 方案 3 份 MD + 证据 → `.pp/wiki/当前任务/[任务名]/`
- 资产/决策 → `ppwiki wiki` + `ppwiki decision`
- 归档 → `.pp/wiki/任务归档/[任务名]_<日期>/`
