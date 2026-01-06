# CoAuthor UI Redesign - Master Plan Index

**Project:** Transform VSCodium fork UI to match professional writing application wireframes
**Timeline:** 11-14 hours (with parallel execution)
**Status:** ✅ Exploration Complete, Ready for Implementation
**Date:** December 29, 2025

---

## 📋 Document Directory

### Primary Documents
1. **progress_ui_redesign_251229.md** (Main Hub)
   - Overall progress tracking
   - Phase status (1-8)
   - Architecture insights
   - Current blockers/next actions
   - **Start here for status updates**

2. **IMPLEMENTATION_STRATEGY.md** (Detailed Execution Guide)
   - Phase-by-phase breakdown
   - File modifications required
   - Parallel execution strategy
   - Risk mitigation
   - Timeline breakdown
   - **Start here before implementing**

3. **QUICK_REFERENCE.md** (Developer Handbook)
   - Files to modify (by priority)
   - CSS variables to create
   - Styling patterns from wireframes
   - Build & validation workflow
   - Testing checklist
   - **Use while coding**

### Supporting Analysis (From Exploration Phase)
- Codebase Architecture Report (embedded in exploration)
- Extension Architecture Analysis (embedded in exploration)
- Both fully detailed for reference

---

## 🎯 High-Level Overview

### What We're Building

**Three UI Views from Wireframes:**

1. **Main Editor View** (Editor with Co-pilot)
   - Professional manuscript editing interface
   - Left sidebar: Navigation tree
   - Center: Full-width editor with formatting toolbar
   - Right: AI Co-pilot suggestions panel (via extension)

2. **Corkboard View** (Project Organization)
   - Scene/section cards in grid layout
   - Card editing and organization
   - Status indicators
   - Create/delete functionality

3. **Source Control View** (Git Integration)
   - Clean branch/commit interface
   - File change tracking (M, U, D badges)
   - Commit message composer
   - Professional styling

---

## 📊 Project Breakdown

### Exploration Phase (COMPLETE ✅)
- **Phase 1:** Codebase mapping → 294 CSS files cataloged, 18 priority files identified
- **Phase 2:** Extension analysis → React webview analyzed, 10 modification points documented
- **Duration:** 3-4 hours
- **Status:** ✅ COMPLETE

### Implementation Phase (READY TO START)
- **Phase 3:** Design system (2-3 hours) → Single agent, foundation for all others
- **Phase 4:** Sidebar styling (3-4 hours) → VSCodium core, left panel
- **Phase 5:** Editor styling (4-5 hours) → VSCodium core, main editor area
- **Phase 6:** Co-pilot panel (3-4 hours) → Extension, right sidebar
- **Phase 7:** Corkboard view (5-6 hours) → Extension, new feature
- **Phase 8:** Testing & polish (4-5 hours) → Validation and optimization
- **Duration:** 11-14 hours (optimized parallel execution)
- **Status:** 🟡 READY TO START

---

## 🚀 Quick Start Guide

### For Project Manager
1. Read this index (you're here) - 5 min
2. Review `progress_ui_redesign_251229.md` - 10 min
3. Check `IMPLEMENTATION_STRATEGY.md` Phase summaries - 15 min
4. Monitor progress using todo list and main progress document

### For Implementation Agent
1. Read this index - 5 min
2. Read `IMPLEMENTATION_STRATEGY.md` (full) - 30 min
3. Read `QUICK_REFERENCE.md` - 15 min
4. Start with assigned phase from strategy doc
5. Update `progress_ui_redesign_251229.md` after each phase

### For Code Review
1. Check `QUICK_REFERENCE.md` for files modified - 5 min
2. Review each phase against wireframes - 10-15 min
3. Verify design tokens used consistently - 10 min
4. Test in running VS Code instance - 20 min

---

## 🗂️ Critical Files Reference

### Will Modify (High Priority)
```
src/vs/workbench/browser/media/workbench.css      (Global styles)
src/vs/workbench/browser/media/sidebar.css        (Left panel)
src/vs/editor/browser/media/editor.css            (Text editor)
src/vs/workbench/browser/media/editorstatus.css   (Tabs & title)
extensions/coauthor-agent/webview-ui/build/assets/index.css (Co-pilot)
product.json                                      (Settings)
```

### Will Create (New Files)
```
src/design-system/tokens.ts                       (Design tokens)
src/design-system/variables.css                   (CSS variables)
extensions/coauthor-agent/src/corkboard/          (New component)
```

### Will Reference (Documentation)
```
wireframes/1_Main_Wireframe.png                    (Target design 1)
wireframes/2_Corkboard_Wireframe.png              (Target design 2)
wireframes/3_Commit_Wireframe.png                 (Target design 3)
```

---

## 📈 Progress Tracking

### Phases Status Board
```
Phase 1: Codebase Mapping            ✅ COMPLETE
Phase 2: Extension Analysis           ✅ COMPLETE
Phase 3: Design System & Tokens       ⏳ QUEUED
Phase 4: Sidebar Styling              ⏳ QUEUED
Phase 5: Editor Area Styling          ⏳ QUEUED
Phase 6: Co-pilot Panel Updates       ⏳ QUEUED
Phase 7: Corkboard View               ⏳ QUEUED
Phase 8: Testing & Polish             ⏳ QUEUED
```

### Key Milestones
- **Milestone 1:** Design tokens created (Phase 3) → Unblocks all other phases
- **Milestone 2:** VSCodium core styled (Phases 4-5) → 50% visual redesign complete
- **Milestone 3:** Extension styled (Phase 6) → Co-pilot panel matches wireframe
- **Milestone 4:** Corkboard implemented (Phase 7) → New feature complete
- **Milestone 5:** All validated (Phase 8) → Ready for production

---

## 🔧 Technical Execution Summary

### Architecture Insights

**VSCodium (Electron-based VS Code fork)**
- Workbench layout system with 13 major components
- CSS custom properties for runtime theming
- Platform-specific font handling
- Service-based dependency injection

**CoAuthor Extension**
- React webview with Tailwind CSS (162 KB output)
- Bidirectional communication via postMessage API
- 20+ commands and menu contributions
- HeroUI component library for accessibility

### Design System Strategy
- **Single Source of Truth:** Design tokens in TypeScript + CSS variables
- **Color System:** Professional blues, clean neutrals, accent colors
- **Typography:** System fonts + custom monospace for code
- **Spacing:** 4px baseline grid system
- **Components:** Reusable patterns across VSCodium + Extension

### Build & Validation
- Monitor `VS Code - Build` task for compilation
- Test in running VS Code instance after each phase
- Commit after each phase for easy rollback
- Parallel execution of Phases 4-6 reduces timeline by 40%

---

## 📝 Document Maintenance

### Update Schedule
- **After Phase 3:** Update progress with design system completion
- **After Phases 4-6:** Confirm parallel work completion, merge findings
- **After Phase 7:** Document new Corkboard feature
- **After Phase 8:** Final validation summary

### Who Updates What
- **Main Document:** Project lead after each phase
- **Implementation Docs:** Implemented by coding agents
- **Quick Reference:** Updated if patterns change

---

## ✅ Success Criteria

### Code Quality
- ✅ 0 compilation errors after each phase
- ✅ No console errors in running VS Code
- ✅ Design tokens used consistently
- ✅ Code follows VSCodium conventions
- ✅ Changes well-commented

### Visual Quality
- ✅ 100% alignment with wireframe designs
- ✅ Professional appearance
- ✅ Consistent spacing and typography
- ✅ Dark/light theme support

### Technical Quality
- ✅ Extension loads successfully
- ✅ Responsive at all viewport sizes
- ✅ No performance regression
- ✅ WCAG AA color contrast compliance

---

## 🔗 Related Files & References

### Wireframes (Design Targets)
- `wireframes/1_Main_Wireframe.png` - Main editor view
- `wireframes/2_Corkboard_Wireframe.png` - Corkboard view
- `wireframes/3_Commit_Wireframe.png` - Source control view

### Build & Development
- `.github/copilot-instructions.md` - VSCode coding standards
- `package.json` - Project dependencies and scripts
- `build/` - Build configuration files
- `scripts/test.sh` - Test runner

### Extension Files
- `extensions/coauthor-agent/package.json` - Extension manifest
- `extensions/coauthor-agent/tailwind.config.js` - Tailwind config
- `extensions/coauthor-agent/webview-ui/` - React webview source

---

## 🎓 Learning Resources

### VS Code Extension Development
- Official: https://code.visualstudio.com/api
- Webviews: https://code.visualstudio.com/api/extension-guides/webview
- Theme Colors: https://code.visualstudio.com/docs/getstarted/theme-color-reference

### VSCodium Fork Information
- Official: https://vscodium.com/
- GitHub: https://github.com/VSCodium/vscodium
- Custom configs: See `product.json` for settings

### Design & UI
- Codicons: https://microsoft.github.io/vscode-codicons/
- HeroUI: https://www.heroui.com/
- Tailwind CSS: https://tailwindcss.com/

---

## 📞 Key Contacts & Resources

### Documentation You Created
- `progress_ui_redesign_251229.md` - Main progress hub
- `IMPLEMENTATION_STRATEGY.md` - Detailed phase guide
- `QUICK_REFERENCE.md` - Developer handbook
- `MASTER_PLAN_INDEX.md` - This document

### Analysis Documents (From Exploration)
- Complete codebase architecture analysis
- Complete extension architecture analysis
- Both embedded in exploration results

---

## 🏁 Next Immediate Steps

### Before Starting Implementation
1. ✅ Ensure this index is understood
2. ✅ Review IMPLEMENTATION_STRATEGY.md
3. ✅ Prepare VS Code with build tasks running
4. ⏳ Begin Phase 3 (Design System)

### During Implementation
1. Run `VS Code - Build` task continuously
2. Test changes in running VS Code instance
3. Commit after each phase
4. Update progress document daily
5. Reference QUICK_REFERENCE.md while coding

### After Each Phase
1. Update progress document
2. Verify no compilation errors
3. Commit to version control
4. Plan next phase execution
5. Adjust timeline if needed

---

## 📊 Project Timeline

```
Phase 1 & 2: Exploration
├─ 3-4 hours (COMPLETE ✅)
└─ Deliverable: Complete architectural blueprint

Phase 3: Design System
├─ 2-3 hours
└─ Deliverable: Reusable design tokens

Phases 4-6: Parallel Execution
├─ Track A: VSCodium styling (4-5 hrs serial)
├─ Track B: Extension styling (3-4 hrs serial)
├─ Parallel: 4-5 hours (reduces from 7-9 hours)
└─ Deliverable: Visual redesign complete

Phase 7: Corkboard Feature
├─ 5-6 hours
└─ Deliverable: New card-based view

Phase 8: Testing & Validation
├─ 4-5 hours
└─ Deliverable: Production-ready code

TOTAL: 11-14 hours (optimized)
```

---

**Project Status:** ✅ READY FOR IMPLEMENTATION
**Last Updated:** December 29, 2025
**Maintained By:** UI Redesign Project Team

**Next Review Point:** After Phase 3 Completion
