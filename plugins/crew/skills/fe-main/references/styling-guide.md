# Frontend Styling Guide

## Tailwind CSS Conventions

### Class Order

```
1. Layout (display, position, flex, grid)
2. Sizing (width, height)
3. Spacing (margin, padding)
4. Typography (font, text)
5. Colors (background, text color, border color)
6. Effects (shadow, opacity)
7. Transitions/Animations
8. Responsive variants
```

```tsx
// Example
<div className="
  flex items-center justify-between
  w-full h-12
  px-4 py-2
  text-sm font-medium
  bg-white text-gray-900 border border-gray-200
  shadow-sm
  transition-colors
  hover:bg-gray-50
  md:px-6
">
```

### Responsive Design

```tsx
// Mobile-first approach
<div className="
  w-full                    /* mobile: full width */
  md:w-1/2                  /* tablet: half width */
  lg:w-1/3                  /* desktop: 1/3 width */
">

// Show/hide
<div className="hidden md:block">Desktop only</div>
<div className="block md:hidden">Mobile only</div>

// Grid
<div className="
  grid grid-cols-1
  sm:grid-cols-2
  lg:grid-cols-3
  xl:grid-cols-4
  gap-4
">
```

### Custom Color Definitions

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
        gray: {
          50: '#f9fafb',
          100: '#f3f4f6',
          500: '#6b7280',
          900: '#111827',
        },
      },
    },
  },
};
```

## CSS Variables

### Theme Tokens

```css
/* styles/globals.css */
:root {
  /* Colors */
  --color-primary: 59 130 246;
  --color-secondary: 107 114 128;
  --color-error: 239 68 68;
  --color-success: 16 185 129;

  /* Spacing */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-4: 1rem;
  --space-6: 1.5rem;

  /* Border Radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 1rem;

  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.dark {
  --color-primary: 96 165 250;
  --color-background: 17 24 39;
  --color-foreground: 249 250 251;
}
```

### Using CSS Variables in Tailwind

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: 'rgb(var(--color-primary) / <alpha-value>)',
      },
      borderRadius: {
        custom: 'var(--radius-md)',
      },
    },
  },
};
```

## Component Styling

### CVA (Class Variance Authority)

```tsx
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  // Base styles
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-primary text-white hover:bg-primary/90',
        secondary: 'bg-secondary text-white hover:bg-secondary/80',
        outline: 'border border-input bg-background hover:bg-accent',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
      },
      size: {
        sm: 'h-8 px-3 text-xs',
        md: 'h-10 px-4 text-sm',
        lg: 'h-12 px-6 text-base',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'md',
    },
  }
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

export function Button({ className, variant, size, ...props }: ButtonProps) {
  return (
    <button
      className={cn(buttonVariants({ variant, size }), className)}
      {...props}
    />
  );
}
```

### cn Utility

```tsx
// lib/utils.ts
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Usage
<div className={cn(
  'base-styles',
  isActive && 'active-styles',
  className
)} />
```

## Dark Mode

### Following System Settings

```tsx
// tailwind.config.js
module.exports = {
  darkMode: 'class', // or 'media'
};

// Usage
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
```

### Theme Toggle

```tsx
// hooks/use-theme.ts
export function useTheme() {
  const [theme, setTheme] = useState<'light' | 'dark' | 'system'>('system');

  useEffect(() => {
    const root = document.documentElement;

    if (theme === 'system') {
      const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches
        ? 'dark'
        : 'light';
      root.classList.toggle('dark', systemTheme === 'dark');
    } else {
      root.classList.toggle('dark', theme === 'dark');
    }
  }, [theme]);

  return { theme, setTheme };
}
```

## Animations

### Tailwind Animations

```tsx
// Built-in
<div className="animate-spin" />   // Spin
<div className="animate-pulse" />  // Pulse
<div className="animate-bounce" /> // Bounce

// Custom
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
};
```

### Transitions

```tsx
// Hover effect
<button className="
  transition-colors duration-200
  bg-blue-500 hover:bg-blue-600
">

// Multiple properties
<div className="
  transition-all duration-300 ease-in-out
  transform hover:scale-105
  opacity-0 group-hover:opacity-100
">
```

## Responsive Utilities

### Breakpoints

```
sm: 640px
md: 768px
lg: 1024px
xl: 1280px
2xl: 1536px
```

### Container

```tsx
// Centered container
<div className="container mx-auto px-4 sm:px-6 lg:px-8">

// Maximum width constraint
<div className="max-w-7xl mx-auto px-4">
```

## Accessibility Styles

### Focus Indicators

```tsx
// Default focus ring
<button className="
  focus:outline-none
  focus-visible:ring-2
  focus-visible:ring-primary
  focus-visible:ring-offset-2
">

// Keyboard focus only
<a className="
  focus:outline-none
  focus-visible:underline
">
```

### Screen Reader Only

```tsx
// sr-only class
<span className="sr-only">Open menu</span>

// Conditional display
<span className="sr-only sm:not-sr-only">Description text</span>
```
