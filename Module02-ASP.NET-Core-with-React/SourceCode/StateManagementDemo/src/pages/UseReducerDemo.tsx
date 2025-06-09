import { useReducer, useState } from 'react';
import StateVisualizer from '../components/StateVisualizer';

// Simple Counter Reducer
interface CounterState {
  count: number;
  step: number;
}

type CounterAction =
  | { type: 'INCREMENT' }
  | { type: 'DECREMENT' }
  | { type: 'RESET' }
  | { type: 'SET_STEP'; payload: number };

const counterReducer = (state: CounterState, action: CounterAction): CounterState => {
  switch (action.type) {
    case 'INCREMENT':
      return { ...state, count: state.count + state.step };
    case 'DECREMENT':
      return { ...state, count: state.count - state.step };
    case 'RESET':
      return { ...state, count: 0 };
    case 'SET_STEP':
      return { ...state, step: action.payload };
    default:
      return state;
  }
};

// Todo List Reducer
interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

interface TodoState {
  todos: Todo[];
  filter: 'all' | 'active' | 'completed';
}

type TodoAction =
  | { type: 'ADD_TODO'; payload: string }
  | { type: 'TOGGLE_TODO'; payload: number }
  | { type: 'DELETE_TODO'; payload: number }
  | { type: 'SET_FILTER'; payload: 'all' | 'active' | 'completed' }
  | { type: 'CLEAR_COMPLETED' };

const todoReducer = (state: TodoState, action: TodoAction): TodoState => {
  switch (action.type) {
    case 'ADD_TODO':
      return {
        ...state,
        todos: [
          ...state.todos,
          {
            id: Date.now(),
            text: action.payload,
            completed: false,
          },
        ],
      };
    case 'TOGGLE_TODO':
      return {
        ...state,
        todos: state.todos.map(todo =>
          todo.id === action.payload
            ? { ...todo, completed: !todo.completed }
            : todo
        ),
      };
    case 'DELETE_TODO':
      return {
        ...state,
        todos: state.todos.filter(todo => todo.id !== action.payload),
      };
    case 'SET_FILTER':
      return {
        ...state,
        filter: action.payload,
      };
    case 'CLEAR_COMPLETED':
      return {
        ...state,
        todos: state.todos.filter(todo => !todo.completed),
      };
    default:
      return state;
  }
};

// Shopping Cart Reducer
interface CartItem {
  id: number;
  name: string;
  price: number;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  total: number;
  discount: number;
}

type CartAction =
  | { type: 'ADD_ITEM'; payload: Omit<CartItem, 'quantity'> }
  | { type: 'REMOVE_ITEM'; payload: number }
  | { type: 'UPDATE_QUANTITY'; payload: { id: number; quantity: number } }
  | { type: 'APPLY_DISCOUNT'; payload: number }
  | { type: 'CLEAR_CART' };

const cartReducer = (state: CartState, action: CartAction): CartState => {
  switch (action.type) {
    case 'ADD_ITEM': {
      const existingItem = state.items.find(item => item.id === action.payload.id);
      let newItems;
      
      if (existingItem) {
        newItems = state.items.map(item =>
          item.id === action.payload.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        );
      } else {
        newItems = [...state.items, { ...action.payload, quantity: 1 }];
      }
      
      const total = newItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);
      
      return {
        ...state,
        items: newItems,
        total: total - (total * state.discount / 100),
      };
    }
    case 'REMOVE_ITEM': {
      const newItems = state.items.filter(item => item.id !== action.payload);
      const total = newItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);
      
      return {
        ...state,
        items: newItems,
        total: total - (total * state.discount / 100),
      };
    }
    case 'UPDATE_QUANTITY': {
      const newItems = state.items.map(item =>
        item.id === action.payload.id
          ? { ...item, quantity: Math.max(0, action.payload.quantity) }
          : item
      ).filter(item => item.quantity > 0);
      
      const total = newItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);
      
      return {
        ...state,
        items: newItems,
        total: total - (total * state.discount / 100),
      };
    }
    case 'APPLY_DISCOUNT': {
      const subtotal = state.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
      
      return {
        ...state,
        discount: action.payload,
        total: subtotal - (subtotal * action.payload / 100),
      };
    }
    case 'CLEAR_CART':
      return {
        items: [],
        total: 0,
        discount: 0,
      };
    default:
      return state;
  }
};

const UseReducerDemo = () => {
  // Counter with useReducer
  const [counterState, counterDispatch] = useReducer(counterReducer, {
    count: 0,
    step: 1,
  });

  // Todo list with useReducer
  const [todoState, todoDispatch] = useReducer(todoReducer, {
    todos: [],
    filter: 'all',
  });
  const [newTodo, setNewTodo] = useState('');

  // Shopping cart with useReducer
  const [cartState, cartDispatch] = useReducer(cartReducer, {
    items: [],
    total: 0,
    discount: 0,
  });

  const addTodo = () => {
    if (newTodo.trim()) {
      todoDispatch({ type: 'ADD_TODO', payload: newTodo.trim() });
      setNewTodo('');
    }
  };

  const filteredTodos = todoState.todos.filter(todo => {
    switch (todoState.filter) {
      case 'active':
        return !todo.completed;
      case 'completed':
        return todo.completed;
      default:
        return true;
    }
  });

  const products = [
    { id: 1, name: 'Laptop', price: 999.99 },
    { id: 2, name: 'Mouse', price: 29.99 },
    { id: 3, name: 'Keyboard', price: 79.99 },
    { id: 4, name: 'Monitor', price: 299.99 },
  ];

  return (
    <div>
      <div className="card">
        <h1 style={{ margin: '0 0 1rem 0', color: '#2c3e50' }}>
          🔄 useReducer Hook Demonstrations
        </h1>
        <p style={{ color: '#6c757d', margin: 0 }}>
          Learn how to manage complex state logic with useReducer. This hook is perfect
          when you have complex state logic that involves multiple sub-values or when
          the next state depends on the previous one.
        </p>
      </div>

      <div className="grid grid-2">
        {/* Simple Counter */}
        <StateVisualizer
          title="Counter with Steps"
          state={counterState}
          actions={
            <>
              <button 
                className="button danger"
                onClick={() => counterDispatch({ type: 'DECREMENT' })}
              >
                -{counterState.step}
              </button>
              <button 
                className="button secondary"
                onClick={() => counterDispatch({ type: 'RESET' })}
              >
                Reset
              </button>
              <button 
                className="button success"
                onClick={() => counterDispatch({ type: 'INCREMENT' })}
              >
                +{counterState.step}
              </button>
            </>
          }
        >
          <div style={{
            fontSize: '2rem',
            fontWeight: 'bold',
            textAlign: 'center',
            padding: '1rem',
            background: '#f8f9fa',
            borderRadius: '4px',
            marginBottom: '1rem',
          }}>
            {counterState.count}
          </div>
          
          <div className="form-group">
            <label>Step Size:</label>
            <input
              className="input"
              type="number"
              value={counterState.step}
              onChange={(e) => counterDispatch({ 
                type: 'SET_STEP', 
                payload: parseInt(e.target.value) || 1 
              })}
              min="1"
            />
          </div>
        </StateVisualizer>

        {/* Todo List */}
        <StateVisualizer
          title="Todo List Manager"
          state={{
            totalTodos: todoState.todos.length,
            activeTodos: todoState.todos.filter(t => !t.completed).length,
            completedTodos: todoState.todos.filter(t => t.completed).length,
            currentFilter: todoState.filter,
          }}
          actions={
            <>
              <button 
                className="button"
                onClick={addTodo}
                disabled={!newTodo.trim()}
              >
                Add Todo
              </button>
              <button 
                className="button danger"
                onClick={() => todoDispatch({ type: 'CLEAR_COMPLETED' })}
                disabled={todoState.todos.filter(t => t.completed).length === 0}
              >
                Clear Completed
              </button>
            </>
          }
        >
          <div className="form-group">
            <label>New Todo:</label>
            <input
              className="input"
              type="text"
              value={newTodo}
              onChange={(e) => setNewTodo(e.target.value)}
              placeholder="Enter todo..."
              onKeyPress={(e) => e.key === 'Enter' && addTodo()}
            />
          </div>
          
          <div className="form-group">
            <label>Filter:</label>
            <select
              className="input"
              value={todoState.filter}
              onChange={(e) => todoDispatch({ 
                type: 'SET_FILTER', 
                payload: e.target.value as 'all' | 'active' | 'completed'
              })}
            >
              <option value="all">All</option>
              <option value="active">Active</option>
              <option value="completed">Completed</option>
            </select>
          </div>
          
          <div style={{ maxHeight: '200px', overflowY: 'auto' }}>
            {filteredTodos.map(todo => (
              <div
                key={todo.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.5rem',
                  padding: '0.5rem',
                  background: '#f8f9fa',
                  borderRadius: '4px',
                  marginBottom: '0.5rem',
                }}
              >
                <input
                  type="checkbox"
                  checked={todo.completed}
                  onChange={() => todoDispatch({ type: 'TOGGLE_TODO', payload: todo.id })}
                />
                <span style={{
                  flex: 1,
                  textDecoration: todo.completed ? 'line-through' : 'none',
                  opacity: todo.completed ? 0.6 : 1,
                }}>
                  {todo.text}
                </span>
                <button
                  className="button danger"
                  style={{ padding: '0.25rem 0.5rem', fontSize: '0.8rem' }}
                  onClick={() => todoDispatch({ type: 'DELETE_TODO', payload: todo.id })}
                >
                  ×
                </button>
              </div>
            ))}
            {filteredTodos.length === 0 && (
              <div style={{
                color: '#6c757d',
                fontStyle: 'italic',
                textAlign: 'center',
                padding: '1rem',
              }}>
                No todos found
              </div>
            )}
          </div>
        </StateVisualizer>
      </div>

      {/* Shopping Cart - Full Width */}
      <StateVisualizer
        title="Shopping Cart Manager"
        state={{
          itemCount: cartState.items.length,
          totalItems: cartState.items.reduce((sum, item) => sum + item.quantity, 0),
          subtotal: cartState.items.reduce((sum, item) => sum + (item.price * item.quantity), 0),
          discount: cartState.discount,
          total: cartState.total,
        }}
        actions={
          <>
            <button 
              className="button secondary"
              onClick={() => cartDispatch({ type: 'APPLY_DISCOUNT', payload: 10 })}
            >
              Apply 10% Discount
            </button>
            <button 
              className="button danger"
              onClick={() => cartDispatch({ type: 'CLEAR_CART' })}
              disabled={cartState.items.length === 0}
            >
              Clear Cart
            </button>
          </>
        }
      >
        <div className="grid grid-2">
          <div>
            <h4 style={{ margin: '0 0 1rem 0' }}>Products</h4>
            <div style={{ display: 'grid', gap: '0.5rem' }}>
              {products.map(product => (
                <div
                  key={product.id}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '0.75rem',
                    background: '#f8f9fa',
                    borderRadius: '4px',
                  }}
                >
                  <div>
                    <strong>{product.name}</strong><br />
                    <small>${product.price.toFixed(2)}</small>
                  </div>
                  <button
                    className="button"
                    style={{ padding: '0.5rem 1rem' }}
                    onClick={() => cartDispatch({ type: 'ADD_ITEM', payload: product })}
                  >
                    Add to Cart
                  </button>
                </div>
              ))}
            </div>
          </div>
          
          <div>
            <h4 style={{ margin: '0 0 1rem 0' }}>Cart Items</h4>
            {cartState.items.length === 0 ? (
              <div style={{
                color: '#6c757d',
                fontStyle: 'italic',
                textAlign: 'center',
                padding: '2rem',
              }}>
                Cart is empty
              </div>
            ) : (
              <div style={{ display: 'grid', gap: '0.5rem' }}>
                {cartState.items.map(item => (
                  <div
                    key={item.id}
                    style={{
                      display: 'flex',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                      padding: '0.75rem',
                      background: '#e9ecef',
                      borderRadius: '4px',
                    }}
                  >
                    <div style={{ flex: 1 }}>
                      <strong>{item.name}</strong><br />
                      <small>${item.price.toFixed(2)} × {item.quantity}</small>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <button
                        className="button secondary"
                        style={{ padding: '0.25rem 0.5rem', fontSize: '0.8rem' }}
                        onClick={() => cartDispatch({ 
                          type: 'UPDATE_QUANTITY', 
                          payload: { id: item.id, quantity: item.quantity - 1 }
                        })}
                      >
                        -
                      </button>
                      <span style={{ minWidth: '2rem', textAlign: 'center' }}>
                        {item.quantity}
                      </span>
                      <button
                        className="button secondary"
                        style={{ padding: '0.25rem 0.5rem', fontSize: '0.8rem' }}
                        onClick={() => cartDispatch({ 
                          type: 'UPDATE_QUANTITY', 
                          payload: { id: item.id, quantity: item.quantity + 1 }
                        })}
                      >
                        +
                      </button>
                      <button
                        className="button danger"
                        style={{ padding: '0.25rem 0.5rem', fontSize: '0.8rem' }}
                        onClick={() => cartDispatch({ type: 'REMOVE_ITEM', payload: item.id })}
                      >
                        ×
                      </button>
                    </div>
                  </div>
                ))}
                
                <div style={{
                  background: '#d4edda',
                  color: '#155724',
                  padding: '1rem',
                  borderRadius: '4px',
                  marginTop: '0.5rem',
                  textAlign: 'right',
                }}>
                  <strong>Total: ${cartState.total.toFixed(2)}</strong>
                  {cartState.discount > 0 && (
                    <div style={{ fontSize: '0.9rem' }}>
                      Discount: {cartState.discount}%
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
      </StateVisualizer>

      <div className="card">
        <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
          💡 useReducer vs useState
        </h2>
        <div className="grid grid-2">
          <div>
            <h3 style={{ color: '#495057' }}>✅ Use useReducer When:</h3>
            <ul style={{ paddingLeft: '1.5rem' }}>
              <li>Complex state logic with multiple sub-values</li>
              <li>Next state depends on previous state</li>
              <li>State transitions are predictable</li>
              <li>You want to optimize performance</li>
              <li>Testing state logic separately</li>
            </ul>
          </div>
          <div>
            <h3 style={{ color: '#495057' }}>✅ Use useState When:</h3>
            <ul style={{ paddingLeft: '1.5rem' }}>
              <li>Simple state values (strings, numbers, booleans)</li>
              <li>Independent state updates</li>
              <li>Quick prototyping</li>
              <li>State logic is straightforward</li>
              <li>Component-specific state</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default UseReducerDemo;
