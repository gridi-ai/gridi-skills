# Frontend Component Pattern Guide

## Component Classification

### 1. Presentational Components (UI)

Pure UI components with no state

```tsx
// components/ui/card.tsx
interface CardProps {
  title: string;
  children: React.ReactNode;
  className?: string;
}

export function Card({ title, children, className }: CardProps) {
  return (
    <div className={cn('rounded-lg border p-6', className)}>
      <h3 className="text-lg font-semibold">{title}</h3>
      <div className="mt-4">{children}</div>
    </div>
  );
}
```

### 2. Container Components (Smart)

Components that hold state and logic

```tsx
// components/containers/user-list-container.tsx
export function UserListContainer() {
  const { data: users, isLoading, error } = useUsers();

  if (isLoading) return <Skeleton />;
  if (error) return <ErrorMessage error={error} />;

  return <UserList users={users} />;
}
```

### 3. Compound Components

Grouping related components

```tsx
// components/ui/tabs.tsx
const TabsContext = createContext<TabsContextValue | null>(null);

export function Tabs({ children, defaultValue }: TabsProps) {
  const [value, setValue] = useState(defaultValue);

  return (
    <TabsContext.Provider value={{ value, setValue }}>
      {children}
    </TabsContext.Provider>
  );
}

Tabs.List = function TabsList({ children }: { children: React.ReactNode }) {
  return <div className="flex border-b">{children}</div>;
};

Tabs.Tab = function Tab({ value, children }: TabProps) {
  const context = useContext(TabsContext);
  const isActive = context?.value === value;

  return (
    <button
      className={cn('px-4 py-2', isActive && 'border-b-2 border-primary')}
      onClick={() => context?.setValue(value)}
    >
      {children}
    </button>
  );
};

Tabs.Panel = function TabPanel({ value, children }: TabPanelProps) {
  const context = useContext(TabsContext);
  if (context?.value !== value) return null;
  return <div className="py-4">{children}</div>;
};

// Usage
<Tabs defaultValue="tab1">
  <Tabs.List>
    <Tabs.Tab value="tab1">Tab 1</Tabs.Tab>
    <Tabs.Tab value="tab2">Tab 2</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel value="tab1">Content 1</Tabs.Panel>
  <Tabs.Panel value="tab2">Content 2</Tabs.Panel>
</Tabs>
```

## Form Patterns

### React Hook Form + Zod

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('Please enter a valid email'),
  password: z.string().min(8, 'Must be at least 8 characters'),
});

type FormData = z.infer<typeof schema>;

export function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    // API call
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Input
        label="Email"
        {...register('email')}
        error={errors.email?.message}
      />
      <Input
        label="Password"
        type="password"
        {...register('password')}
        error={errors.password?.message}
      />
      <Button type="submit" isLoading={isSubmitting}>
        Log In
      </Button>
    </form>
  );
}
```

### Controlled vs Uncontrolled

```tsx
// Controlled - React manages state
const [value, setValue] = useState('');
<Input value={value} onChange={(e) => setValue(e.target.value)} />

// Uncontrolled - DOM manages state (react-hook-form)
const { register } = useForm();
<Input {...register('email')} />
```

## Data Fetching Patterns

### React Query

```tsx
// Data retrieval
export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => api.get('/users'),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

// Data mutation
export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateUserDto) => api.post('/users', data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}

// Usage
function UserList() {
  const { data, isLoading, error } = useUsers();
  const createUser = useCreateUser();

  if (isLoading) return <Loading />;
  if (error) return <Error error={error} />;

  return (
    <>
      <ul>
        {data.map(user => <UserItem key={user.id} user={user} />)}
      </ul>
      <Button onClick={() => createUser.mutate(newUserData)}>
        Add
      </Button>
    </>
  );
}
```

### Suspense + Error Boundary

```tsx
// Component
function UserProfile() {
  const { data } = useSuspenseQuery({
    queryKey: ['user', userId],
    queryFn: () => api.get(`/users/${userId}`),
  });

  return <Profile user={data} />;
}

// Usage (parent)
<ErrorBoundary fallback={<ErrorMessage />}>
  <Suspense fallback={<ProfileSkeleton />}>
    <UserProfile />
  </Suspense>
</ErrorBoundary>
```

## Modal/Dialog Patterns

### Portal-Based Modal

```tsx
// components/ui/modal.tsx
import { createPortal } from 'react-dom';

export function Modal({ isOpen, onClose, children }: ModalProps) {
  if (!isOpen) return null;

  return createPortal(
    <div className="fixed inset-0 z-50">
      <div
        className="fixed inset-0 bg-black/50"
        onClick={onClose}
      />
      <div className="fixed inset-0 flex items-center justify-center p-4">
        <div className="bg-white rounded-lg max-w-md w-full">
          {children}
        </div>
      </div>
    </div>,
    document.body
  );
}
```

### Confirmation Dialog Hook

```tsx
// hooks/use-confirm.ts
export function useConfirm() {
  const [state, setState] = useState<{
    isOpen: boolean;
    message: string;
    resolve: ((value: boolean) => void) | null;
  }>({
    isOpen: false,
    message: '',
    resolve: null,
  });

  const confirm = useCallback((message: string): Promise<boolean> => {
    return new Promise((resolve) => {
      setState({ isOpen: true, message, resolve });
    });
  }, []);

  const handleConfirm = () => {
    state.resolve?.(true);
    setState({ isOpen: false, message: '', resolve: null });
  };

  const handleCancel = () => {
    state.resolve?.(false);
    setState({ isOpen: false, message: '', resolve: null });
  };

  return { confirm, state, handleConfirm, handleCancel };
}

// Usage
const { confirm, state, handleConfirm, handleCancel } = useConfirm();

const handleDelete = async () => {
  if (await confirm('Are you sure you want to delete this?')) {
    deleteItem();
  }
};
```

## List/Table Patterns

### Virtualization

```tsx
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
  });

  return (
    <div ref={parentRef} className="h-[400px] overflow-auto">
      <div style={{ height: `${virtualizer.getTotalSize()}px` }}>
        {virtualizer.getVirtualItems().map((virtualItem) => (
          <div
            key={virtualItem.key}
            style={{
              height: `${virtualItem.size}px`,
              transform: `translateY(${virtualItem.start}px)`,
            }}
          >
            {items[virtualItem.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}
```

### Infinite Scroll

```tsx
import { useInfiniteQuery } from '@tanstack/react-query';
import { useInView } from 'react-intersection-observer';

function InfiniteList() {
  const { ref, inView } = useInView();

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ['items'],
    queryFn: ({ pageParam = 1 }) => fetchItems(pageParam),
    getNextPageParam: (lastPage) => lastPage.nextPage,
  });

  useEffect(() => {
    if (inView && hasNextPage) {
      fetchNextPage();
    }
  }, [inView, hasNextPage, fetchNextPage]);

  return (
    <div>
      {data?.pages.map((page) =>
        page.items.map((item) => <Item key={item.id} item={item} />)
      )}
      <div ref={ref}>
        {isFetchingNextPage && <Spinner />}
      </div>
    </div>
  );
}
```

## State Patterns

### Loading/Error/Empty States

```tsx
interface AsyncStateProps<T> {
  isLoading: boolean;
  error: Error | null;
  data: T | undefined;
  loadingComponent?: React.ReactNode;
  errorComponent?: React.ReactNode;
  emptyComponent?: React.ReactNode;
  children: (data: T) => React.ReactNode;
  isEmpty?: (data: T) => boolean;
}

function AsyncState<T>({
  isLoading,
  error,
  data,
  loadingComponent = <Skeleton />,
  errorComponent,
  emptyComponent = <EmptyState />,
  children,
  isEmpty = (d) => Array.isArray(d) && d.length === 0,
}: AsyncStateProps<T>) {
  if (isLoading) return <>{loadingComponent}</>;
  if (error) return <>{errorComponent || <ErrorMessage error={error} />}</>;
  if (!data || isEmpty(data)) return <>{emptyComponent}</>;
  return <>{children(data)}</>;
}

// Usage
<AsyncState
  isLoading={isLoading}
  error={error}
  data={users}
  isEmpty={(users) => users.length === 0}
>
  {(users) => <UserList users={users} />}
</AsyncState>
```
