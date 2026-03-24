# Component Design Guide

## Core Principles

### 1. Consistency
- Same style for components with the same purpose
- Leverage design system variables
- Follow padding/margin rules

### 2. Accessibility
- Do not convey information through color alone
- Sufficient touch targets
- Clear focus states

### 3. Responsiveness
- Define all states (hover, active, disabled)
- Consider loading states
- Provide error state feedback

## Component Catalog

### 1. Button

#### Properties
| Property | Options |
|----------|---------|
| variant | primary, secondary, ghost, danger |
| size | sm, md, lg |
| state | default, hover, active, disabled, loading |
| icon | left, right, only |

#### Specification
```
[Primary Button - Medium]
- Height: 40px
- Padding: 16px 24px
- Border radius: 8px
- Font: 16px / Semibold
- Background: --color-primary
- Text: white
```

### 2. Input

#### Properties
| Property | Options |
|----------|---------|
| type | text, password, email, number |
| state | default, focus, error, disabled |
| size | sm, md, lg |

#### Specification
```
[Input - Medium]
- Height: 44px
- Padding: 12px 16px
- Border: 1px solid --color-border
- Border radius: 8px
- Font: 16px / Regular
```

### 3. Card

#### Properties
| Property | Options |
|----------|---------|
| variant | default, elevated, outlined |
| padding | sm, md, lg |
| interactive | true, false |

#### Specification
```
[Card - Default]
- Padding: 24px
- Border radius: 12px
- Background: white
- Shadow: 0 1px 3px rgba(0,0,0,0.1)
```

### 4. Modal

#### Properties
| Property | Options |
|----------|---------|
| size | sm (400px), md (560px), lg (720px) |

#### Structure
```
┌─────────────────────────────────┐
│ Header                     [X]  │ ← 64px
├─────────────────────────────────┤
│                                 │
│           Content               │ ← Variable
│                                 │
├─────────────────────────────────┤
│           [Cancel] [Confirm]    │ ← 72px
└─────────────────────────────────┘
```

### 5. Toast / Notification

#### Variants
- Success: Green icon
- Error: Red icon
- Warning: Yellow icon
- Info: Blue icon

#### Specification
```
[Toast]
- Width: 360px (max)
- Padding: 16px
- Border radius: 8px
- Position: Top-right
- Animation: slide-in-right
```

### 6. Table

#### Structure
```
┌──────────┬──────────┬──────────┐
│  Header  │  Header  │  Header  │ ← 48px, bold, background color
├──────────┼──────────┼──────────┤
│   Cell   │   Cell   │   Cell   │ ← 56px
├──────────┼──────────┼──────────┤
│   Cell   │   Cell   │   Cell   │
└──────────┴──────────┴──────────┘
```

#### States
- Default
- Hover: Row background color change
- Selected: Checkbox + highlight
- Sorting: Header icon display

### 7. Form

#### Layout
```
Label *
┌─────────────────────────────┐
│ Input                       │
└─────────────────────────────┘
Helper text

[Gap: 24px between fields]

Label
┌─────────────────────────────┐
│ Input                       │
└─────────────────────────────┘
Error message (red)
```

#### Spacing
- Label to input: 8px
- Input to helper text: 4px
- Between fields: 24px
- Between sections: 32px

### 8. Navigation

#### Header
```
┌─────────────────────────────────────────────────┐
│ [Logo]     Nav1  Nav2  Nav3      [Search] [👤]  │
└─────────────────────────────────────────────────┘
Height: 64px
Padding: 0 24px
```

#### Sidebar
```
┌────────────────┐
│ [Logo]         │
├────────────────┤
│ > Menu 1       │
│   Menu 2       │
│   Menu 3       │
├────────────────┤
│ Section        │
│   Menu 4       │
│   Menu 5       │
└────────────────┘
Width: 240px (expanded) / 64px (collapsed)
```

## Icon Guide

### Sizes
| Size | Pixels | Usage |
|------|--------|-------|
| xs | 16px | Inline text |
| sm | 20px | Inside buttons |
| md | 24px | Default |
| lg | 32px | Emphasis |

### Styles
- Default: Outlined
- Active: Filled
- Stroke: 1.5px
