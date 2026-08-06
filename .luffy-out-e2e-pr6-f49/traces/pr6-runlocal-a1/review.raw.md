## 🏴‍☠️ Luffy Review — PR #6

**Verdict:** APPROVE  
**Confidence:** high  
**Score:** 95/100  
**Review effort:** 3/5  

### Summary
This PR fixes the regex for street splitting in the Odoo toolset to handle more address formats robustly and adds multiple realistic address fixtures for Danish localization modules. The regex fix improves parsing accuracy of street name, number, and suffix parts. Tests for street field behavior were updated to cover these cases. The PR is well-scoped and improves core address parsing correctness, important for address validation and formatting. The Danish localized fixture updates improve test realism for the relevant modules.

### Walkthrough
- Updates regex in `odoo/tools/misc.py` for `street_split` function/logic to fix street splitting with more accurate capture of street name, number, and additional info.
- Adjusts and adds tests in `addons/base_address_extended/tests/test_street_fields.py` to cover new regex behavior and edge cases in street splitting.
- Adds/updates XML address fixtures in Danish localization addons (`addons/l10n_dk_nemhandel`, `addons/l10n_dk_oioubl`) reflecting realistic invoice data for Denmark to improve end-to-end coverage.
- Removes redundant or outdated sample files with minimal noisy diffs in XML test fixtures.

### Blocking
- None

### Key findings

| Severity | File | Issue | Trigger scenario |
|----------|------|-------|------------------|
| medium | `odoo/tools/misc.py` | Regex complexity and maintainability risk | The new regex for street splitting is complex, which may affect maintainability or produce unexpected edge cases with very unusual address formats. |
| medium | `addons/base_address_extended/tests/test_street_fields.py` | Test coverage for street splitting | The tests cover typical examples well, but edge cases with international address formats with uncommon separators might still slip. |

### Security audit
No

### Suggestions
- Add comments in `misc.py` explaining the regex groups in `street_split` for maintainability.
- Consider adding a few more edge case tests for addresses with very unusual formats or whitespace patterns in `test_street_fields.py`.

### Code suggestions
#### Add regex explanation comment (`odoo/tools/misc.py`)
```diff
- # existing regex definition code
+ # Regex for street split: captures street name, number, and number2/suffix.
+ # Groups: 1=street name, 2=street number, 3=additional number2 or suffix if present.
+ # Handles numeric ranges, letter suffixes, and punctuation separators like '-', ',' etc.
```
Why: Helps maintainers understand the complex regex logic.

### Nits
- None

### Tests & risk
- Relevant tests added/updated: yes (street splitting behavior tested, fixtures added)
- Coverage: covers typical and many complex address cases; some very rare edge cases could be added
- Risk: medium — regex fixes can silently break edge cases if new addresses fall outside tested patterns
- Rollback: easy — revert regex and tests if issues found

### What I checked
- Full diff for `addons/base_address_extended/tests/test_street_fields.py` (test logic and data)
- `odoo/tools/misc.py` street_split regex changes and surrounding code
- Representative samples of XML fixture files from `addons/l10n_dk_nemhandel` and `addons/l10n_dk_oioubl` to confirm fixture content updates
- Verified test inclusion and coverage relevance for new regex and fixtures

---
*Luffy · Hermes Agent · OpenRouter · memory-backed review*
