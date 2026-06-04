---
name: pp-sync-v2
description: 同步 PPWIKI v2(提资产入 wiki + 证据留存)。审查通过后从 archive 剥离的独立同步:读 执行方案.md 五类清单 + 证据/审查报告.md · LLM 提可复用单元 → ppwiki wiki --create/update + 维护 _INDEX · 决策走 ppwiki decision 模块 · 逻辑流程图/关联代码字段直接取审查报告。不做物理归档(留给 /pp-archive-v2)· 可独立反复跑。
disable-model-invocation: true
---

# /pp-sync-v2 — 同步 PPWIKI(提资产入 wiki + 证据留存)

## 定位

```
审查通过后,把本次产出沉淀成「可复用知识」+ 留存「证据链」:
  · 资产 → ppwiki wiki(函数/前端组件/类/数据标准/业务装配)
  · 决策 → ppwiki decision(用 decision 模块 · 不再塞进 wiki)
  · 证据 → 归集 clarify/plan/execute/review 四阶段证据 · 确保随任务留存
不做物理归档(mv 留给 /pp-archive-v2)· 同步可独立反复跑(幂等:查重 → update)
```

> 本命令 = 旧 /pp-archive-v2 里「资产提取 + 分类路由 + 落 wiki」三段剥离独立。

## 调用方式

```
/pp-sync-v2 <任务名>
读 .pp/wiki/当前任务/[任务名]/{执行方案.md, 对话和澄清.md, 证据/审查报告.md}
```

## 一、前置校验(任一失败即阻断)

| 检查 | 通过标志 |
|---|---|
| 任务目录存在 | `.pp/wiki/当前任务/[任务名]/` 在 |
| 已审查且通过 | 证据/审查报告.md 在 **且 0 must 未解**(未审/有 must → 提示先 /pp-review-v2) |
| ppwiki 连接 | `ppwiki('system --health')` 成功 |

## 二、5 步流程

```
Step 1 · 前置校验(上表)
Step 2 · 资产提取(读 执行方案.md 五类清单 + 审查报告 → LLM 归纳)
Step 3 · 分类路由(LLM 按 wiki scope 落位 · 决策走 decision)
Step 4 · 落 wiki/decision + 维护 _INDEX(查重 → update / 无则 create)· 每条写后回读确认
Step 5 · 证据归集校验 → 下一步建议 /pp-archive-v2
```

## 三、资产提取(Step 2 · 五类清单 → wiki 资产)

| 执行方案章节 | wiki 资产类型 |
|---|---|
| §1 复用清单 | 已有 · 不入 wiki(信任已存在) |
| §2 优化清单 | 已有 · 检查是否需 update wiki 说明 |
| §3 修改清单 | 业务装配条目可能要更新 |
| §4 清理清单 | 反向 · 删除的 wiki 条目需 `wiki --delete` |
| §5 新建清单 | **主入 wiki 来源** · 函数/类/组件/数据 |

同时扫:
- **决策类** → 对话和澄清.md §3 已锁定决策 + clarify decide 记录 → `decision --create`
- **逻辑流程图** → 证据/审查报告.md §2 实测 mermaid(直接灌 wiki 字段 · 不重画)
- **关联代码** → 证据/代码证据.md + 审查报告「调用维」发现(直接灌 wiki 字段)
- **参考类** → 证据/外部证据.md 的外部 URL/文档 → 参考/<scope>/<name>

## 四、分类路由(Step 3)

```
函数原子        →  复用/函数库/<领域>/<name>
前端组件        →  复用/前端组件库/<领域>/<name>
后端类          →  复用/类库/<领域>/<name>
数据 schema     →  复用/数据标准/<领域>/<name>
业务 feature    →  前端/<scope>/<name> 或 后端/<scope>/<name>
外部参考        →  参考/<scope>/<name>
重大架构决策    →  decision --create(ppwiki decision 模块 · 不入 wiki 树)
```

## 五、落 wiki/decision + 维护索引(Step 4 · op 以 system --help 为准)

> 条目内容按公约沟通写:简介/详细说明 = 大白话 · 结论先行 · 落 md 用 md 表 · 新手能直接复用(不堆术语)。

```
for asset in 提取列表:
    r = ppwiki('wiki --search', {'query': asset.关键词, 'scope': asset.scope_top})
    if 命中同名:
        ppwiki('wiki --update', {'id': <existing>, 'mode':'patch',
                                 '简介':…, '详细说明':…, '关联代码':[…],
                                 '逻辑流程图': <取审查报告 §2>})
    else:
        ppwiki('wiki --create', {'id': <new>, '简介':…, '标签':[…],
                                 '逻辑流程图': <取审查报告 §2>,
                                 '关联代码': <取代码证据>, '详细说明':…})

for d in 决策列表:
    查重 ppwiki('decision --list' / '--get') → 命中则跳过/update · 无则 ppwiki('decision --create', {…})
    # 决策也查重(对齐 wiki 路径)· 保 sync 反复跑幂等 · 参数查 system --help

维护索引(复用/_INDEX · 前端/_INDEX · 后端/_INDEX):
    ppwiki('wiki --update', {'id':'<scope>/_INDEX','mode':'append','field':'详细说明','text':<新行>})

仅架构变更才碰 _README:
    if 引入新框架/新数据流:
        ppwiki('wiki --update', {'id':'_README','mode':'patch', …})

写后验证(读事实不读记忆 · 不假设成功):
    for 每条刚 create/update 的 id:
        ppwiki('wiki --get' / 'wiki --search') → 确认落库
        未命中 → 重试 1 次 · 仍失败 → 报错阻断(不静默)
```

## 六、证据归集校验(Step 5)

```
确认 证据/ 四份齐全(随任务留存 · 供 /pp-archive-v2 一起 mv):
  ✓ 代码证据.md   (clarify)
  ✓ 外部证据.md   (clarify)
  ✓ 执行验收.md   (execute)
  ✓ 审查报告.md   (review)
缺任一 → 提示回对应阶段补 · 不替它造证据。
```

## 七、用户视角对话样例

```
你: /pp-sync-v2 PPAgent纯MCP核心重构

AI: [同步 PPWIKI v2] 启动 — 提资产入 wiki + decision · 证据归集

    进度 [●○○○○]  1/5 · 前置校验 ✓(审查报告在 · ppwiki 连接)
    进度 [●●○○○]  2/5 · 资产提取(读五类清单 + 审查报告)
       ✓ 新建函数: PPAgent 工具封顶 cap_tool_output (pp_agent.py:xxx)
       ✓ 决策:    工具输出 64KB 字节封顶根治 502
       ✓ 流程图:  取审查报告 §2 实测 mermaid
    进度 [●●●○○]  3/5 · 分类路由
       函数 → 复用/函数库/Agent库/cap_tool_output
       决策 → decision --create(64KB 封顶)
       业务 → 后端/PPAgent/纯MCP核心
    进度 [●●●●○]  4/5 · 落库 + 维护索引
       [1/3] 复用/函数库/Agent库/cap_tool_output   无重复 → create ✓
       [2/3] decision 64KB 封顶                     → create ✓
       [3/3] 后端/PPAgent/纯MCP核心                 命中 → update ✓
       维护 复用/_INDEX · 后端/_INDEX 各追加一行 ✓
    进度 [●●●●●]  5/5 · 证据归集 ✓ 四份齐全
    ┌──── 同步完成 ────┐
    │ 下一步:/pp-archive-v2(写总结 + 物理归档)│
    └──────────────────┘
```

## 八、失败 / 边界

| 情况 | 处置 |
|---|---|
| 审查报告不存在 | 阻断 · 提示先 /pp-review-v2 |
| ppwiki MCP 未连接 | 提示 `install_mcp.sh` 安装 · 阻断 |
| wiki --create 路径冲突 | 自动改 update(合并) |
| wiki --update 不存在 | 自动改 create |
| _INDEX 不存在 | 自动 create 基础版 |
| 证据缺份 | 提示回对应阶段补 · 不代造 |
| op/参数不确定 | `ppwiki('system --help',{module:'wiki'/'decision'})` 核对 |

## 九、不做的事

- ❌ 不物理归档(mv 留给 /pp-archive-v2)
- ❌ 不写业务代码
- ❌ 不无脑 create(查重 → update)
- ❌ 不破坏历史 wiki 条目
- ❌ 不把决策塞 wiki(走 decision 模块)
- ❌ 不重画流程图(取审查报告 §2 实测图)
- ❌ 不替证据缺口造数据

## 十、与既有命令的关系

| 命令 | 阶段 | 定位 |
|---|---|---|
| /pp-clarify-v2 | 澄清/根因 | 三源调研 + 逻辑层单问 + 证据留存 |
| /pp-plan-v2 | 方案 | 3 份 MD + 子代理模拟验证 |
| /pp-execute-v2 | 执行 | 循环跑命令式验收 → 全绿 |
| /pp-review-v2 | 审查 | 自我攻击 5 维 + 真实测试 + 跨任务回顾 |
| **/pp-sync-v2** | 同步 | **本命令** · 提资产入 wiki/decision + 证据留存 |
| /pp-archive-v2 | 归档 | 写总结 + 物理归档 |

```
唯一链路:/pp-clarify-v2 → /pp-plan-v2 → /pp-execute-v2 → /pp-review-v2 → /pp-sync-v2 → /pp-archive-v2
          澄清/根因      方案        执行          审查+回顾      同步        归档
```
