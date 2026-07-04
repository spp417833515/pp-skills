# 依赖:ppwiki MCP(Python · 由 pptasks 提供)

pp-skills 全程读写 ppwiki(澄清条目 / wiki 知识库 / task 阶段状态机 / review / decision)。
**没有 ppwiki MCP,这 6 个技能跑不起来。**

## 架构(技能 ≠ MCP)

```
pp-skills(本仓库 · 提示词技能 · 无语言)
   │ 调用
ppwiki MCP = pptasks 的 mcpd.server(Python)
   │ import
pp_engine / pp_wiki(Python · 知识库内核)
```

→ ppwiki MCP 是 **Python** 的(整个 PP 生态都是 Python);本仓库只是上面的技能层。

## 安装(推荐:用 pptasks 自带的 install_mcp.sh)

PP 生态里 `pptasks` 已提供一键安装器,自动做好**项目隔离 + 双工具注册**:

```bash
cd <pptasks 仓库>
./install_mcp.sh --claude --codex  /abs/path/to/你的项目
```

它会:
- 目标项目无 `.pp/wiki/` → 自动初始化知识库骨架
- 写/合并 `<项目>/.mcp.json`:`command` 指向 pptasks 的 `mcp_start.sh` shim,`args = ["--project", "<项目绝对路径>"]`
  → **项目隔离**:每个项目一份 `.mcp.json`,各自指向自己的 `.pp/wiki/`
- `--codex` 同步写 `~/.codex/config.toml` 全局 MCP;`--claude` 清理同名 local MCP(避免覆盖 project 配置)
- 启动自检:确认 server 不会立刻崩

> 前置:pptasks 的 `.venv` 已就绪(在 pptasks 仓库先跑一次 `./start.sh`)。
> `mcp_start.sh` 用 `.venv/bin/python -m mcpd.server` 拉起,并强制 `PYTHONUTF8=1`(防中文字段断流)。

## 手动配置(没有 pptasks 安装器时的兜底)

`<项目>/.mcp.json`(Claude 项目级 · Codex 同理写 `~/.codex/config.toml`):

```json
{ "mcpServers": { "ppwiki": {
    "command": "<pptasks>/mcp_start.sh",
    "args": ["--project", "<你的项目绝对路径>"]
} } }
```

## 验证

```
wiki('system --health')     → {ok:true, ...} 即通
wiki('system --ops')        → tools 字段 = 六工具→模块域映射,ops 为全量命令清单
```

> 六工具收口(2026-07-04):单 server(ppwiki)对外直接暴露六个一等工具
> `clarify / task / wiki / skill / memory / project_flow`,签名统一 `<tool>(op, params)`;
> op 仍是 `"模块 --动作"`,但必须经所属工具调用(decision/review/state 归 task 门,
> system/reusable_code 归 wiki 门)。走错门会返回 WRONG_TOOL 并指路。

## 为什么是 Python 不是 Node

ppwiki/pp_engine 是 Python,MCP 直接 import 同进程调用。换 Node 必然要架 Python↔Node 桥
或重写知识引擎 = 缝补 + 双信源 + 重复造轮子。生态 89 py / 0 js,Python 是唯一合理选择。
