## 🏴‍☠️ Luffy Review — PR #6

**Verdict:** APPROVE  
**Confidence:** high  
**Score:** 95/100  
**Review effort:** 3/5  

### Summary
This PR fixes the `street_split` regex in `odoo/tools/misc.py` and updates address-related fixtures and tests, primarily in `addons/base_address_extended` and `addons/l10n_dk_nemhandel` / `l10n_dk_oioubl` modules. The changes are focused and include test modifications and additions that verify the regex fix and the correctness of address splitting. The diff is moderate-sized but appears well-contained around the regex fix and its associated test data.

### Walkthrough
- Fixed and improved the `street_split` regex in `odoo/tools/misc.py` to handle street addresses more robustly.
- Updated `addons/base_address_extended/tests/test_street_fields.py` with tests to cover the regex fix and related edge cases.
- Modified various `oioubl` XML test fixtures under `addons/l10n_dk_nemhandel/tests/test_files/from_odoo/` and `addons/l10n_dk_oioubl/tests/test_files/from_odoo/` for test data alignment with changes.
- General cleanup and minor test improvements to support more accurate street parsing logic.

### Blocking
- None

### Key findings

| Severity | File | Issue | Trigger scenario |
|----------|------|-------|------------------|
| None — no high-confidence defects in new code. |

### Security audit
No — no security concerns in regex fix or test fixture updates.

### Suggestions
- Consider adding comments in `odoo/tools/misc.py` explaining the new regex pattern for maintainability and clarity, as regexes are non-trivial to interpret.
- Consider adding a few more explicit edge cases around international street formats if not already covered in tests, for broader future coverage.

### Code suggestions

#### Add explanatory regex comment (`odoo/tools/misc.py`)
```diff
- street_split = re.compile(r"^(.+?)([a-zA-Z]+)((?:\s*(?:[0123456789]+(?:[a-zA-Z]|))*)?)$")
+ # Regex to split street into main part, street type suffix, and optional number/letter parts
+ street_split = re.compile(r"^(.+?)([a-zA-Z]+)((?:\s*(?:[0123456789]+(?:[a-zA-Z]|))*)?)$")
```
Why: Improves maintainability by documenting regex intent since it is key parsing logic.

### Nits
- None significant; code and tests follow existing style and conventions.

### Tests & risk
- Relevant tests added/updated: yes  
- Coverage: Tests cover the fixed regex splitting behavior and related edge cases in addresses.  
- Risk: low — focused regex fix with corresponding test coverage mitigates risk.  
- Rollback: easy — revert regex and test fixture changes.

### What I checked
- `odoo/tools/misc.py` for regex fix  
- `addons/base_address_extended/tests/test_street_fields.py` for test changes  
- Multiple `addons/l10n_dk_nemhandel` and `addons/l10n_dk_oioubl` XML test fixtures for consistency of test data  
- Confirmed diff not truncated and no suspicious or risky code beyond the intended regex fix and test updates.

---
*Luffy · Hermes Agent · OpenRouter · memory-backed review*
