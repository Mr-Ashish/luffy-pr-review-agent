## 🏴‍☠️ Luffy Review — PR #6

**Verdict:** APPROVE  
**Confidence:** high  
**Score:** 95/100  
**Review effort:** 2/5  

### Summary
This PR updates the `street_split` regex in `odoo/tools/misc.py` to fix address parsing. It also touches related logic in the `base_address_extended` module and updates multi-locale test fixtures for address handling. The change appears well-covered by existing and added tests, including detailed unit tests for the street splitting behavior.

### Walkthrough
- `odoo/tools/misc.py:street_split` — core updated regex for splitting street address into components with improved accuracy.
- `addons/base_address_extended/models/res_partner.py` — update and consume the `street_split` function for partner street fields computation and inverse.
- `addons/base_address_extended/tests/test_street_fields.py` — tests verify that street field computations produce expected street_name, street_number, and street_number2 for diverse address formats.
- Several localization modules updated with fixtures reflecting the new address splitting logic.

### Blocking
- None

### Key findings

| Severity | File | Issue | Trigger scenario |
|----------|------|-------|------------------|
| None — no high-confidence defects in new code. | | | |

### Security audit
No

### Suggestions
- Consider reviewing and documenting the regex in `street_split` for maintainability given its complexity.
- Ensure all locales relying on address splitting have tests aligned with the new regex behavior.

### Code suggestions

#### Slight doc improvement in `street_split` function (`odoo/tools/misc.py`)
```diff
- def street_split(street):
+ def street_split(street):
+     """
+     Splits a street address into components:
+     - street_name: The main street name without building or door number
+     - street_number: The building number or main address number
+     - street_number2: Additional door or apartment number
+     """
```
Why: Improves clarity on what the function returns, aiding future maintainers.

### Nits
- None

### Tests & risk
- Relevant tests added/updated: yes (notably `addons/base_address_extended/tests/test_street_fields.py`)
- Coverage: Covers common and complex address formats including doors, apartments, multiple separators.
- Risk: Low — Address splitting is improved and tested; minimal backward compatibility risk given test coverage.
- Rollback: Easy — regex can be reverted or adjusted as needed.

### What I checked
- Core `street_split` code and its regex at `odoo/tools/misc.py`
- `addons/base_address_extended/models/res_partner.py` integration and computed fields usage
- Comprehensive test coverage under `addons/base_address_extended/tests/test_street_fields.py`
- Presence of updated data fixtures in multiple localization addons for consistency

---
*Luffy · Hermes Agent · OpenRouter · memory-backed review*
