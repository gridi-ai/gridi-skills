# Accessibility Design Guide

## WCAG 2.1 Criteria

### Level A (Required)
- Alternative text for all images
- All functionality accessible via keyboard
- Restrict flashing content

### Level AA (Recommended)
- Color contrast ratio of 4.5:1 or higher
- Text resizable
- Consistent navigation

## Color

### Contrast Ratios
| Usage | Minimum Contrast |
|-------|-----------------|
| Body text | 4.5:1 |
| Large text (18px+) | 3:1 |
| UI components | 3:1 |

### Verification Tools
- Figma: Stark plugin
- Chrome: Accessibility Insights

### Color Blindness Considerations
- Add patterns/icons when using red and green together
- Do not convey information through color alone

```
❌ Red dot = error, Green dot = success
✅ ✗ Error message, ✓ Success message
```

## Typography

### Minimum Sizes
- Body text: 16px
- Secondary text: 14px
- Labels: 12px (use uppercase or bold)

### Line Spacing
- Body text: 1.5 (150%)
- Headings: 1.2 (120%)

### Fonts
- Sans-serif fonts recommended
- Use only regular and bold weights
- Underline only for links

## Touch Targets

### Minimum Sizes
- Mobile: 44 x 44px
- Desktop: 24 x 24px

### Spacing
- Minimum 8px between touch targets

```
✅ Sufficient touch area
┌─────────────────────────────┐
│     ┌─────────────────┐     │
│     │     Button      │     │ ← 44px+ including padding
│     └─────────────────┘     │
└─────────────────────────────┘

❌ Touch area too small
┌─────────┐
│ Button  │ ← 32px
└─────────┘
```

## Focus States

### Focus Ring
- Color: Primary or high-contrast color
- Thickness: 2px or more
- Offset: 2px

```css
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}
```

### Focus Order
- Logical tab order
- Focus trap within modals
- Provide skip links

## Form Accessibility

### Labels
- All inputs must have an associated label
- Placeholder cannot replace a label
- Mark required fields (`*` + screen reader text)

```html
<label for="email">
  Email <span aria-label="required">*</span>
</label>
<input id="email" type="email" required>
```

### Error Messages
- Associate with input field (aria-describedby)
- Display with color + icon
- Provide clear resolution instructions

```html
<input
  id="email"
  aria-invalid="true"
  aria-describedby="email-error"
>
<span id="email-error" role="alert">
  ✗ Please enter a valid email address
</span>
```

## Images and Icons

### Alternative Text
| Type | Handling |
|------|----------|
| Informational image | Describe the meaning |
| Decorative image | alt="" |
| Link image | Describe the link purpose |
| Icon button | aria-label |

```html
<!-- Informational -->
<img src="chart.png" alt="2024 revenue chart: January $1M, February $1.5M">

<!-- Decorative -->
<img src="decoration.png" alt="" role="presentation">

<!-- Icon button -->
<button aria-label="Close">
  <svg>...</svg>
</button>
```

## Modals/Dialogs

### Focus Management
1. Move focus to the first focusable element when the modal opens
2. Cycle focus within the modal (trap)
3. Return focus to the trigger element when closed

### ARIA
```html
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="modal-title"
  aria-describedby="modal-desc"
>
  <h2 id="modal-title">Modal Title</h2>
  <p id="modal-desc">Modal description</p>
</div>
```

## Checklist

### Design Phase
- [ ] Verify color contrast
- [ ] Check touch target sizes
- [ ] Design focus states
- [ ] Display error states beyond color alone
- [ ] Check minimum text sizes

### Development Handoff
- [ ] Specify ARIA attributes per component
- [ ] Define focus order
- [ ] Define keyboard interactions
- [ ] Provide alternative text
