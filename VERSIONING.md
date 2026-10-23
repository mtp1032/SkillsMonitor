# SkillsMonitor Versioning Protocol

SkillsMonitor uses a clear, predictable semantic versioning model (*Sematic Versioning*) as described below:

### *PATCH (x.y.Z)*  
Internal changes only. No API or behavioral changes. PATCH increments include:

- Internal refactoring  
- Performance improvements  
- Bug fixes that are transparent to the player.  
- Version changes
- Documentation updates  
- Code cleanup  
- Reorganization  
- Pure refactoring (even large-scale)

PATCH changes:
- Are not visible to the user/player and are always safe and backward-compatible.

---

### *MINOR (x.Y.z)*  

Backward-compatible behavioral or feature changes, As such MINOR increments include:

- New *optional* features  
- New public functions  

*MINOR changes*

- May change behavior in ways that matter to users.  For example, the addition of adding the ability to see the skillup requirements for specific herbs or ores has no effect on previous versions of SkillsMonitor

MINOR releases remain backward-compatible but introduce new capabilities.

---

### MAJOR (X.y.z)

Changes or new architectural functionality that require the player to reinstall.
MAJOR increments include:
- New functionality. For example, I plan to add an inventory feature (mouseover a node reveals the number of those items currently in the player's bags).
****MAJOR changes:***

- Usually, but not always, require the player to reinstall the addon 

---

## LibStub Version Encoding

SkillsMonitor uses LibStub’s integer version encoding:

- 0.1.0 → 100
- 1.0.0 → 10000
- 1.2.3 → 10203
