# 🧠 Kawa.ai — System Approach

## 📌 Overview

Kawa.ai is built around a **stateless, self-contained LLM request model**. Every interaction with a large language model (LLM) includes all necessary context and operates independently of prior interactions. This architectural choice brings several critical benefits:

* **🧩 Modularity** — Each request is atomic and context-rich, allowing easy debugging, testing, and reuse.
* **🚀 Scalability** — Because no shared session or memory is required, Kawa can scale horizontally across multiple workers or environments.
* **🔄 Flexibility** — You can switch between different LLMs (e.g., OpenAI, Gemini, Mistral) mid-project without compatibility issues or extra refactoring.

---

## 🔁 Workflow Overview

The Kawa.ai lifecycle follows a series of structured steps from initial user prompt to a fully generated and editable project. Here's how it works:

---

### 🧾 1. Request Creation (Project Planning)

Users start by describing their app idea in **natural language** via the Kawa web interface. This request is enriched by a **system prompt** defined in [`prompts/project_plan.md`](prompts/project_plan.md) and sent to the LLM.

The result is a **comprehensive project plan**, returned in a structured JSON format like:

```json
{
  "appName": "generate_name_for_the_application",
  "user": {
    "frontEnd": {
      "screen": ["ScreenName1", "ScreenName2", "..."]
    }
  },
  "nextAgent": {
    "model-structure": {
      "ModelName": {
        "property1": "dataType",
        "property2": "dataType"
      }
    },
    "frontEnd": {
      "designReference": "Description of design reference",
      "screen": [
        { "ScreenName1": "Functional + layout details" },
        ...
      ],
      "device-cache": [
        {
          "keyName": {
            "dataType": "Type",
            "description": "Purpose of cached data"
          }
        }
      ]
    }
  },
  "message": "Initial message to be shown to the user"
}
```

---

### 🏗️ 2. Project Creation

Once the plan is received, Kawa:

1. Sends two additional prompts [`project_structure.md`](prompts/project_structure.md) and [`project_files.md`](prompts/project_files.md) to the LLM to generate the folder structure and necessary source files.
2. Initializes a Git repository to **track file changes and support version control**.
3. Launches the project using local runtime services and returns the **preview URL** to the user.

---

### 🧑‍💻 3. Application Interaction & Development

Users can now:

* View the live preview in the **web interface**.
* Debug and explore the app using the integrated **VS Code server debugger**.
* Manage, rename, or delete apps through the dashboard.

This creates a **real-time, editable development environment** with LLMs acting as collaborative AI developers.

---

### ✏️ 4. Editing & Iteration

To make changes to the app, users type their request (again in natural language). The frontend wraps this into a structured payload:

```json
{
  "projectId": "project_id",
  "currentScreen": "current_screen_name",
  "prompt": "user_message"
}
```

From here:

1. **Validation**: The backend checks that the project and screen exist.
2. **Contextual Analysis**: The server sends the user prompt, the **project directory tree**, and **current screen name** to the LLM. The LLM replies with a list of files or components it needs to update.
3. **File Collection & Code Generation**:

   * The backend sends the required files along with the prompt to the LLM.
   * The LLM returns **generated code** for modified or new files.
   * If any new dependencies are introduced, the backend **installs them automatically**.
4. **File Update & Return**:

   * The backend saves changes to the file system.
   * The updated project is now live again and downloadable.

---

## 🧩 Why Stateless Requests?

This design philosophy  **self-contained LLM requests**  is key to Kawa’s robustness and flexibility:

* Avoids dependency on session or memory context, reducing LLM hallucination risks.
* Enables **multi-agent LLM coordination** by letting each agent handle specific tasks independently (e.g. one LLM handles design, another handles data models).
* Supports **LLM hot-swapping**, letting you test prompts across different models without rebuilding project logic.

---

## 📚 Further Reading
check the prompts directory for more details on how Kawa.ai uses LLMs to generate and edit projects:
- [Project Planning](prompts/project_plan.md) - How Kawa generates a comprehensive project plan from user input.
- [Navigation Flow](prompts/navigation_flow.md) - How Kawa structures app navigation flow.
- [Project Structure](prompts/structure.md) - How Kawa defines the folder structure, file organization and initial files.
- [Code Planning](prompts/code_planner.md) - How Kawa prepares the code structure and logic for each screen.
- [Code Generation](prompts/coder.md) - How Kawa generates the actual Flutter code.
---

## 🙌 Summary

Kawa.ai is not just a tool — it's a development methodology. By shifting from session-based to stateless LLM requests, it makes app creation with AI:

* **Predictable**
* **Modular**
* **Scalable**
* **Beautifully hackable**

This architecture is the engine behind Kawa’s bold vision: giving every developer their own AI-powered dev team.

