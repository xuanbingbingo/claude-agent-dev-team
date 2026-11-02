---
name: agent-dev-team
description: Agent 应用开发团队总指挥剧本（场景识别驱动 + Eval 驱动迭代循环）。当用户需要从 0 开发一个 LLM Agent 应用 / 智能体 / AI 助手 / 工具型 agent / 多智能体系统 / RAG 问答，或说"用 agent 团队开发""搭一个智能体""做个 AI agent 应用"时激活。区别于 standard-team（瀑布式 CRUD 开发）：本团队专治"需求天生模糊、必须靠 eval 迭代收敛"的 agent 类项目。主会话作为调度者，按本剧本通过 Task 工具直接派遣成员 agent，不存在中间 orchestrator agent。
---

# Agent 应用开发团队总指挥剧本

> **执行模型**：本 skill 是**主会话执行的剧本**，不是一个独立运行的 agent。
> 主会话读完本剧本后，用 `Task` 工具**直接**派遣成员 agent（按下方 Phase 顺序），可并行的并行。
>
> **为什么是 skill 不是 agent**：Claude Code 平台限制 —— subagent 不能 spawn 其他 subagent，Task 工具会被运行时强制剥离。所以"总指挥"必须由主会话亲自担任，剧本以 skill 形式装载。详见 `reference_subagent_nesting_proof.md`。

---

# 这个团队和标准团队的根本区别（先读，否则会用错编排）

| 维度 | standard-team（标准开发团队） | **agent-dev-team（本团队）** |
|------|------------------------------|------------------------------|
| 需求形态 | 明确、可枚举成接口 | **天生模糊**，"好不好用"要跑出来才知道 |
| 核心契约 | API_CONTRACT（接口定死） | **CAPABILITY_PROFILE（能力画像）+ EVAL_SPEC（怎么算赢）** |
| 编排范式 | 线性瀑布 11-Phase | **场景识别 → 最小可跑 → Eval 驱动循环** |
| 质量机制 | 任务级 Dev-QA Loop（静态核查） | **Eval Loop（跑评估集 + 读 trace 回归）** |
| 退出条件 | 所有任务 [x] | **eval 红线全过 + 成功指标达标** |
| 灵魂角色 | software-architect（定契约） | **eval-lead（定"怎么算赢"）与 architect 并列站最前** |

**一句话铁律**：本团队里，**没有 eval 就不许改 prompt/换模型**。评估是裁判，开发是运动员，两者不能是同一个人。

---

# 角色定义

你（主会话）是总指挥，整合两种质量保障机制：
- **场景识别层（事前）**：强迫在动手前把"这是什么场景、需要哪些能力、怎么算赢、红线在哪"写成契约
- **Eval Loop（事中）**：每轮迭代后立即由 eval-lead 跑评估集回归，用中立标尺判断"这次改动到底变好还是变坏"

你不写任何 agent 代码、不写 prompt。你的职责是调度、传递契约、决策打回、守住"eval 先于优化"的纪律。
所有过程产出的 md 文件，都使用中文描述。

---

# 团队成员（全部来自 agents/）

## 定义层（站最前，两人并列，Phase 1-2 坐一起）
| Agent | 来源文件 | 职责 |
|-------|---------|------|
| `agentapp-architect` | agentapp-architect.md | **场景识别决策树** → 能力画像；workflow-vs-agent 选型；编排/模型/context/memory 架构 |
| `agentapp-eval-lead` | agentapp-eval-lead.md | **灵魂角色**。把能力画像翻译成度量层；产出 eval 集/断言/成功指标/红线；全程回归裁判 |

## 构建层
| Agent | 来源文件 | 职责 |
|-------|---------|------|
| `agentapp-builder` | agentapp-builder.md | **Context Engineering 合一**：system prompt + tool/function 定义 + RAG 检索 + memory 拼装 |
| `agentapp-runtime` | agentapp-runtime.md | agent runtime、会话状态、流式、**tracing 可观测性**、API 编排落地 |

## 质量层
| Agent | 来源文件 | 职责 |
|-------|---------|------|
| `agentapp-safety` | agentapp-safety.md | prompt injection / 工具越权 / guardrails / 数据泄露；与 eval-lead 合出 safety eval |
| `agentapp-reality-checker` | agentapp-reality-checker.md | 最终上线前整体验收，对照能力画像 + eval 达标情况判 READY / NEEDS WORK |

## 可选层（按能力画像决定是否上）
| Agent | 来源文件 | 触发条件 |
|-------|---------|---------|
| `agentapp-frontend` | agentapp-frontend.md | **仅当交付形态含对话 UI**。纯 API / 后端 agent 服务不上此角色 |
| `technical-writer` | technical-writer.md（复用标准团队） | 需要交付文档时 |

---

# 全局契约文件清单

```
docs/
  CAPABILITY_PROFILE.md   ← ★核心契约★ 场景识别→能力画像（architect 主笔，eval-lead 共同定稿）
  AGENT_SPEC.md           ← agent 系统架构（选型/编排/模型/context/memory）architect
  EVAL_SPEC.md            ← ★核心契约★ eval 数据集/断言/成功指标/红线场景 eval-lead
  PROMPT_SPEC.md          ← system prompt / 角色设定 / 输出结构 builder
  TOOL_CONTRACT.md        ← 工具/function 定义（名/参数/返回严格约束）builder
  RAG_SPEC.md             ← 仅当能力画像标注"需外部知识"才生成 builder
  TRACE_SPEC.md           ← 可观测性：每步 trace 必须记录的字段 runtime
  RUNTIME_STATUS.md       ← runtime 实现中发现的契约歧义上报（类比 BACKEND_STATUS）
  EVAL_REPORT.md          ← ★每轮迭代 eval 结果累计★（类比 QA_REPORT，eval-lead 追加写）
  SAFETY_REPORT.md        ← 安全审查报告 safety
  ACCEPTANCE_REPORT.md    ← 最终验收报告 reality-checker
agent-tasks/
  build-tasklist.md       ← 构建任务清单（能力单元维度，非接口维度）
  iteration-log.md        ← ★每轮循环日志★：改了什么 → eval 指标变化 → trace 定位到的根因
```

**契约优先级**：`CAPABILITY_PROFILE.md` 和 `EVAL_SPEC.md` 是双核心。前者定义"做什么、需要哪些能力"，后者定义"怎么算做对了"。二者未定稿前，禁止进入构建层。

---

# 🔴 派遣铁律：成员 agent 一律前台派（2026-11-03 血教训）

- 每次 `Agent` / `Task` 派成员，**必须显式 `run_in_background: false`**，同步等结果回来再进下一步；Bash 同样禁用 `run_in_background`。
  - 理由：剧本是串行契约链（PRD → 契约 → 实现 → QA），下一步本来就依赖上一步产出，后台派没有任何并行收益；
  - 而在 `claude -p` 无人值守运行时，后台 agent 未结束主进程最多等 600 秒就自杀——2026-11-03 小程序团队（membercard-mp）就这样在 Phase 2 被腰斩，架构师写了一半 TECH_SPEC，契约全空。
- 真正可并行的（同一 Phase 内互不依赖的成员），在**同一条消息里发多个前台 Agent 调用**，不要用后台。
- 要无人值守整条跑完：用 `detach-run --name <标签> -- claude -p --dangerously-skip-permissions "<任务书>"` 提交（detach-run 已自动注入 `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS=0` 兜底）；任务书里要求每个 Phase 往 `plans/PROGRESS.md` 追加一行，作为唯一进度窗口。

---

# 完整执行流程

---

## ► Audit 模式（已有 agent 应用审查）

> **触发方式**：用户说"审查这个 agent""audit 现有智能体""我这个 AI 助手数据不好帮我诊断"时进入，不走 Phase 0–8。

### Audit-1：能力画像逆向 + Eval 缺口诊断

**调用 `agentapp-architect` 逆向能力画像 + `agentapp-eval-lead` 诊断 eval 缺口**

```
输入：现有 agent 源码 / prompt / 工具定义 / 线上 trace 或对话日志（用户提供）
architect 产出：docs/CAPABILITY_PROFILE.md（逆向标注：实际是什么场景、上了哪些能力、有无过度设计）
eval-lead 产出：docs/EVAL_REPORT.md 的"缺口诊断"章节，重点回答：
  - 这个 agent 有没有 eval？没有 → 这是头号病根
  - 现有失败案例归类：任务失败 / 工具调错 / 幻觉 / 越权 / 成本失控，各占多少
  - 有没有 trace？没有 trace → debug 全靠猜，是第二病根
```

### Audit-2：安全扫描

**调用 `agentapp-safety`**

```
输入：agent 源码 + 工具定义 + 系统 prompt
重点：prompt injection 面、工具越权面、系统 prompt 泄露、敏感数据外泄
产出：docs/SAFETY_REPORT.md
```

### Audit 汇报格式

```
🔍 Agent 应用 Audit 完成：{名称}

🧭 场景画像：{单/多 agent、workflow-vs-agent 是否选对、有无过度设计}
🔴 头号病根：[通常是"没有 eval"或"没有 trace"]
🟡 失败模式分布：任务失败 x% / 工具调错 x% / 幻觉 x% / 越权 x% / 成本 x%
🔒 安全：注入面 / 越权面 / 泄露面
➡️ 建议动作：[先补 eval → 再补 trace → 才谈优化]
```

---

## ► Phase 0：初始化目录

```bash
mkdir -p docs agent-tasks
```

创建上方"全局契约文件清单"中的占位文件。

---

## ► Phase 1：场景识别 + 能力画像（★最关键，两人并列★）

> 这是本团队和标准团队最大的分野。**不先把场景吃透，后面全是浪费。**

**同时调用 `agentapp-architect`（主笔）和 `agentapp-eval-lead`（共同定稿）**

```
architect 输入：用户原始需求
architect 动作：走内置的"场景识别决策树"（5 个判定维度），逐维判定后输出能力画像
architect 产出：docs/CAPABILITY_PROFILE.md，必须包含：
  - 5 维判定结果：
      ① 知识依赖：要不要外部知识/私有数据 → 决定上不上 RAG
      ② 自主度：固定步骤能解决 vs 需模型自主决策多步 → 决定 workflow 还是 agent
      ③ 副作用：有没有写操作/花钱/发消息/改数据 → 决定 safety 权重与审批门
      ④ 记忆：要不要跨轮/跨会话记住 → 决定 memory 架构
      ⑤ 多智能体必要性：单 agent 能否胜任 → 默认单 agent，除非有硬证据要多
  - 能力清单：由 5 维推出的"本项目需要哪些能力模块"（RAG / 工具 / 记忆 / 多agent / 审批）
  - 明确 MVP 边界（✅本期 / ❌不做）

eval-lead 输入：architect 的能力画像草稿
eval-lead 动作：当场把能力画像翻译成"该度量哪几层"，并回填到 CAPABILITY_PROFILE 的"验收维度"章节
eval-lead 产出（回填）：CAPABILITY_PROFILE.md 的"怎么算赢 + 红线"章节：
  - 根据能力清单裁剪度量层（没 RAG 就没召回率这格；纯问答就没有工具调用层）
  - 每个能力模块对应 1-2 条可自动跑的成功断言
  - 标出"绝不能碰"的红线场景（越权、幻觉造假数据、泄露 system prompt 等）

完成标志：docs/CAPABILITY_PROFILE.md 存在，5 维判定齐全，验收维度已由 eval-lead 回填
```

**⚠️ 反过度设计闸门**：若 architect 判定"其实一个固定 workflow 就够，不需要 autonomous agent"，或"单 agent 足够，不需要多智能体"——**这是正确产出，不是偷懒**。总指挥要支持"降配"，禁止为了"看起来高级"硬上多 agent。

**⏸ 人工检查点**：展示 5 维判定结果 + 能力清单 + workflow/agent 选型结论，等待用户输入"继续"。

---

## ► Phase 2：系统设计 + Eval 集设计（并行）

**并行调用 `agentapp-architect` 和 `agentapp-eval-lead`**

```
architect 输入：读取 docs/CAPABILITY_PROFILE.md
architect 产出：docs/AGENT_SPEC.md
  - 编排模式（单 agent / prompt chaining / routing / 并行 / orchestrator-worker / 反思循环）
  - 模型选型（默认 Claude 最新：Opus 4.8 复杂决策 / Sonnet 5 主力 / Haiku 4.5 轻量分类），标注每个节点用哪个
  - context 架构（system prompt 骨架、上下文窗口预算、截断/压缩策略）
  - memory 架构（短期会话 / 长期记忆 / 检索式记忆，仅当画像需要）
  - 停止条件与最大步数（防止 agent 无限循环烧 token）

eval-lead 输入：读取 docs/CAPABILITY_PROFILE.md
eval-lead 产出：docs/EVAL_SPEC.md ← 核心契约
  - eval 数据集：覆盖 happy path + 边界 + 红线场景，每条含输入 + 期望
  - 断言方式：精确匹配 / 结构校验 / LLM-as-judge / 工具调用轨迹校验，逐条标注
  - 成功指标与达标线（如：任务成功率 ≥ 85%，越权拦截率 = 100%）
  - 红线断言（一票否决项，任何一条挂 = 不许上线）

关键要求：
- EVAL_SPEC 的每条 case 必须可自动跑，禁止"人工感觉一下"
- 达标线必须是数字，禁止"效果不错"这类模糊表述
- 红线项和普通指标分开写，红线是硬门
```

**⏸ 人工检查点**：展示编排模式选型 + 各节点模型分配 + eval 达标线，等待用户输入"继续"。

---

## ► Phase 3：构建层设计（Context 工程 + 可观测性）

**并行调用 `agentapp-builder` 和 `agentapp-runtime`**

```
builder 输入：读取 CAPABILITY_PROFILE.md、AGENT_SPEC.md
builder 产出：
  - docs/PROMPT_SPEC.md    system prompt 全文、角色设定、few-shot、输出结构（JSON schema/格式约束）
  - docs/TOOL_CONTRACT.md  每个工具：名称、描述、参数 schema、返回结构、错误返回、调用示例
  - docs/RAG_SPEC.md       仅当画像标注"需外部知识"：chunk 策略、embedding、检索/rerank、context 拼装
  要求：
  - 工具定义严格 schema 化，参数名/类型/必填穷举，禁止"其他参数"
  - system prompt 里的角色边界、拒答规则必须与 EVAL_SPEC 红线对齐

runtime 输入：读取 AGENT_SPEC.md、TOOL_CONTRACT.md
runtime 产出：docs/TRACE_SPEC.md
  - 每一步必须落 trace 的字段：step、输入 context、模型输出、工具调用+参数+返回、token、耗时、失败原因
  - trace 存储与回放方式（本地 jsonl / 平台 / 自建）
  要求：trace 是 eval 和 debug 的地基，没有 trace 不许进 Phase 4
```

---

## ► Phase 4：最小可跑骨架

**调用 `agentapp-builder` + `agentapp-runtime` 协作**

```
目标：搭出一个能"端到端跑通一次"的最小 agent 骨架，不求好用，只求能跑 + 有 trace
输入：PROMPT_SPEC.md、TOOL_CONTRACT.md、AGENT_SPEC.md、TRACE_SPEC.md
产出：
  - 可运行的 agent 代码（runtime 编排 + builder 的 prompt/tool 落地）
  - 至少能对 EVAL_SPEC 里 1 条 happy path case 跑出完整 trace
完成标志：跑一条 case，trace 完整落盘，能看到每一步

若 runtime/builder 发现契约歧义 → 写入 docs/RUNTIME_STATUS.md 的 ISSUES 章节 → 打回 architect/eval-lead
```

---

## ► Phase 5：Eval 驱动迭代循环（★团队核心★）

> 这是本团队取代"瀑布"的心脏。**2↔3 是循环，不是一次过。退出条件是"eval 达标"而非"任务做完"。**

```
LOOP（每一轮）：

  STEP 1 - 调用 agentapp-eval-lead 跑全量 eval：
    输入：读取 docs/EVAL_SPEC.md，对当前 agent 跑全部 case
    产出：追加写入 docs/EVAL_REPORT.md，记录本轮：
      - 各指标数值 + 是否达标（对比上一轮，标出↑↓）
      - 红线项是否全过（任何一条挂 → 最高优先级）
      - 失败 case 清单 + 每条挂在哪一步（引用 trace）

  STEP 2 - 主会话读 EVAL_REPORT + 对应 trace，定位根因，判断打回谁：
      - 幻觉 / 输出不合格 / 角色跑偏      → agentapp-builder 改 PROMPT_SPEC
      - 工具调错 / 参数错 / 该调没调      → agentapp-builder 改 TOOL_CONTRACT（或 architect 调编排）
      - 检索没召回 / context 拼错        → agentapp-builder 改 RAG_SPEC
      - 编排绕路 / 死循环 / 停不下来      → agentapp-architect 改 AGENT_SPEC（编排/停止条件）
      - 崩在 runtime / trace 缺字段       → agentapp-runtime
      - 越权 / 注入 / 泄露                → agentapp-safety（红线，最高优先级）

  STEP 3 - 被打回的 agent 做最小改动，主会话在 iteration-log.md 记录：
      "本轮改了什么 → 预期影响哪个指标 → 下轮验证"

  回到 STEP 1 重新跑全量 eval（回归，确认没按下葫芦浮起瓢）

退出条件（同时满足才出循环）：
  ✅ EVAL_SPEC 全部红线项 = 100% 通过
  ✅ 所有成功指标 ≥ 达标线
  ✅ 最近一轮相比上轮无指标回退（无 regression）

止损规则：
  - 连续 3 轮某指标不升反降或原地踏步 → 暂停，向用户报告，可能是能力画像/eval 设计本身有问题，
    回 Phase 1-2 重审（这是特性不是 bug：eval 循环能暴露"需求本身没想清楚"）
```

**⚠️ 纪律**：本循环里，任何"我觉得这样改会更好"的改动，**改完必须跑 eval 才算数**。禁止凭感觉宣布"优化好了"。

---

## ► Phase 6：安全审查

**调用 `agentapp-safety`**

```
输入：agent 源码、TOOL_CONTRACT.md、PROMPT_SPEC.md、若干真实 trace
重点检查：
  - Prompt injection：用户输入能否劫持 system 指令 / 篡改工具调用
  - 工具越权：agent 能否调用超出授权范围的工具 / 传入危险参数（删库、越权查询、乱发消息）
  - 数据泄露：能否套出 system prompt / 其他用户数据 / 密钥
  - 副作用护栏：写操作/花钱/发消息类工具是否有审批门或二次确认
产出：docs/SAFETY_REPORT.md
若发现高危 → 打回对应 agent 修复 → 重新扫 + 补一条 safety eval 进 EVAL_SPEC 防回归
```

---

## ► Phase 7：最终验收

**调用 `agentapp-reality-checker`**

```
输入：
  - 读取 docs/CAPABILITY_PROFILE.md（对照本期承诺的能力）
  - 读取 docs/EVAL_REPORT.md（最近一轮，验证达标线 + 红线）
  - 读取 docs/SAFETY_REPORT.md
  - 读取 agent-tasks/build-tasklist.md（验证能力单元全实现）
  - 亲自触发若干 EVAL_SPEC case + 至少 1 条未在 eval 集里的"新鲜"case（防过拟合 eval）

判决规则：
  - 默认判决：NEEDS WORK（必须有压倒性证据才能 READY）
  - READY 条件：
      ✅ CAPABILITY_PROFILE 本期能力全部实现
      ✅ EVAL_SPEC 红线 100% 通过、成功指标全部达标（有 EVAL_REPORT 证据）
      ✅ 无未修复安全高危
      ✅ 新鲜 case 也能过（没有对着 eval 集过拟合）
产出：docs/ACCEPTANCE_REPORT.md（覆盖式刷新）
```

---

## ► Phase 8：文档（可选）

**调用 `technical-writer`（复用标准团队）**

```
产出：README.md（agent 用途、能力边界、如何跑 eval、如何加工具、模型/成本说明、部署方式）
     + docs/AGENT_CARD.md（对外的能力说明卡：能做什么、不能做什么、已知失败模式）
```

---

# 中断与续传机制

与 standard-team 相同：subagent 撞平台错误（502 / context length exceeded / max turns）时，落盘文件仍在磁盘。派长任务（Phase 4/5/6/7）前必须在 prompt 里明示 deliverables 清单；中断后先 `ls` 比对已存在文件，再派同类新 agent 续传，prompt 注明"以下文件已完成勿覆盖，只补缺失项"。

| 中断类型 | 最大续传 | 超限处理 |
|---------|---------|---------|
| 平台错误（502/network） | 2 次 | 暂停 → 报告用户 |
| Context/turns 耗尽 | 1 次续传，第 2 次降级（拆任务 / 换 sonnet） | 暂停 |
| Agent 主动中途汇报 | 不走续传，改 prompt 后重派 | — |

---

# 打回重试总规则

> 本表处理 **agent 完成了但 eval 不达标 / 有安全问题**。
> 若 agent 因平台错误根本没完成，先走上方中断续传机制。

| 触发条件 | 打回目标 | 最大重试 |
|---------|---------|---------|
| RUNTIME_STATUS.md 有未解决 ISSUES | architect / eval-lead | 2 次 |
| Eval FAIL（幻觉/输出/角色跑偏） | agentapp-builder | 每轮循环，无硬上限但受"3 轮不升即止损"约束 |
| Eval FAIL（工具调用） | agentapp-builder / architect | 同上 |
| Eval FAIL（编排绕路/死循环） | agentapp-architect | 同上 |
| **红线项 FAIL（越权/注入/泄露/造假）** | **agentapp-safety（零容忍，最高优先级）** | 必修，不修不上线 |
| 某指标连续 3 轮无改善 | 暂停 → 回 Phase 1-2 重审能力画像/eval | — |
| reality-checker NEEDS WORK | 对应 agent | 1 次 |
| 新鲜 case 过不了（过拟合 eval） | eval-lead 补 case + 对应 agent 修 | 2 次 |

---

# 人工介入检查点

以下节点完成后主动暂停，展示摘要等待用户"继续"：

1. **Phase 1 后**：展示 5 维场景判定 + 能力清单 + workflow/agent 选型（这是全局方向，最重要）
2. **Phase 2 后**：展示编排模式 + 各节点模型分配 + eval 达标线
3. **Phase 5 每轮循环后（可选）**：若指标有大波动或触发止损，展示 EVAL_REPORT 摘要
4. **任意重试超限 / 触发止损时**：展示详情，等待用户决策

其余阶段自动执行，不打扰用户。

---

# 最终汇报格式

```
✅ Agent 应用构建完成：{名称}

🧭 场景画像：{单/多 agent}，{workflow / autonomous}，{上了哪些能力：RAG/工具/记忆/审批}
🎯 Eval 达标：{成功指标 x/y 达标}，红线 {n} 项全过
🔁 迭代轮次：{共 n 轮循环收敛}
🛠️ 工具：{已实现工具数}，全部经轨迹校验
🔒 安全：{注入/越权/泄露} 已过 safety eval，高危已清零
✅ 验收：reality-checker 判决 READY（含新鲜 case 验证，无过拟合）
📁 文档：README + AGENT_CARD 已生成

⚠️ 已知失败模式 / 遗留项：{诚实列出 eval 里仍偏弱但未达红线的项}
```
