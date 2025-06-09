import { useState } from 'react';
import StateVisualizer from '../components/StateVisualizer';

const UseStateDemo = () => {
  // Simple state examples
  const [count, setCount] = useState(0);
  const [name, setName] = useState('');
  const [isVisible, setIsVisible] = useState(true);
  
  // Object state example
  const [user, setUser] = useState({
    name: '',
    email: '',
    age: 0,
  });
  
  // Array state example
  const [items, setItems] = useState<string[]>([]);
  const [newItem, setNewItem] = useState('');

  // Complex state example
  const [formData, setFormData] = useState({
    personal: {
      firstName: '',
      lastName: '',
    },
    contact: {
      email: '',
      phone: '',
    },
    preferences: {
      newsletter: false,
      notifications: true,
    },
  });

  const handleUserUpdate = (field: keyof typeof user, value: string | number) => {
    setUser(prev => ({
      ...prev,
      [field]: value,
    }));
  };

  const addItem = () => {
    if (newItem.trim()) {
      setItems(prev => [...prev, newItem.trim()]);
      setNewItem('');
    }
  };

  const removeItem = (index: number) => {
    setItems(prev => prev.filter((_, i) => i !== index));
  };

  const updateFormData = (section: string, field: string, value: any) => {
    setFormData(prev => ({
      ...prev,
      [section]: {
        ...prev[section as keyof typeof prev],
        [field]: value,
      },
    }));
  };

  return (
    <div>
      <div className="card">
        <h1 style={{ margin: '0 0 1rem 0', color: '#2c3e50' }}>
          📊 useState Hook Demonstrations
        </h1>
        <p style={{ color: '#6c757d', margin: 0 }}>
          Learn how to manage local component state with the useState hook.
          Watch how state changes trigger re-renders and update the UI.
        </p>
      </div>

      <div className="grid grid-2">
        {/* Simple State */}
        <StateVisualizer
          title="Simple State (Primitives)"
          state={{ count, name, isVisible }}
          actions={
            <>
              <button 
                className="button" 
                onClick={() => setCount(prev => prev + 1)}
              >
                Count: {count}
              </button>
              <button 
                className="button secondary" 
                onClick={() => setCount(0)}
              >
                Reset Count
              </button>
              <button 
                className="button success" 
                onClick={() => setIsVisible(!isVisible)}
              >
                Toggle Visibility
              </button>
            </>
          }
        >
          <div className="form-group">
            <label>Name:</label>
            <input
              className="input"
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Enter your name"
            />
          </div>
          
          {isVisible && (
            <div style={{
              background: '#d4edda',
              color: '#155724',
              padding: '1rem',
              borderRadius: '4px',
              marginTop: '1rem',
            }}>
              Hello, {name || 'Anonymous'}! You've clicked {count} times.
            </div>
          )}
        </StateVisualizer>

        {/* Object State */}
        <StateVisualizer
          title="Object State"
          state={user}
          actions={
            <>
              <button 
                className="button" 
                onClick={() => handleUserUpdate('age', user.age + 1)}
              >
                Age Up
              </button>
              <button 
                className="button secondary" 
                onClick={() => setUser({ name: '', email: '', age: 0 })}
              >
                Clear User
              </button>
            </>
          }
        >
          <div style={{ display: 'grid', gap: '1rem' }}>
            <div className="form-group">
              <label>Name:</label>
              <input
                className="input"
                type="text"
                value={user.name}
                onChange={(e) => handleUserUpdate('name', e.target.value)}
                placeholder="Enter name"
              />
            </div>
            
            <div className="form-group">
              <label>Email:</label>
              <input
                className="input"
                type="email"
                value={user.email}
                onChange={(e) => handleUserUpdate('email', e.target.value)}
                placeholder="Enter email"
              />
            </div>
            
            <div className="form-group">
              <label>Age: {user.age}</label>
              <input
                className="input"
                type="range"
                min="0"
                max="100"
                value={user.age}
                onChange={(e) => handleUserUpdate('age', parseInt(e.target.value))}
              />
            </div>
          </div>
        </StateVisualizer>

        {/* Array State */}
        <StateVisualizer
          title="Array State"
          state={{ items, itemCount: items.length }}
          actions={
            <>
              <button 
                className="button" 
                onClick={addItem}
                disabled={!newItem.trim()}
              >
                Add Item
              </button>
              <button 
                className="button danger" 
                onClick={() => setItems([])}
                disabled={items.length === 0}
              >
                Clear All
              </button>
            </>
          }
        >
          <div className="form-group">
            <label>Add New Item:</label>
            <div style={{ display: 'flex', gap: '0.5rem' }}>
              <input
                className="input"
                type="text"
                value={newItem}
                onChange={(e) => setNewItem(e.target.value)}
                placeholder="Enter item name"
                onKeyPress={(e) => e.key === 'Enter' && addItem()}
              />
              <button 
                className="button" 
                onClick={addItem}
                disabled={!newItem.trim()}
              >
                Add
              </button>
            </div>
          </div>
          
          <div style={{ marginTop: '1rem' }}>
            <strong>Items ({items.length}):</strong>
            <div style={{ 
              display: 'flex', 
              flexDirection: 'column', 
              gap: '0.5rem',
              marginTop: '0.5rem'
            }}>
              {items.map((item, index) => (
                <div 
                  key={index}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    background: '#f8f9fa',
                    padding: '0.5rem',
                    borderRadius: '4px',
                  }}
                >
                  <span>{item}</span>
                  <button
                    className="button danger"
                    style={{ padding: '0.25rem 0.5rem', fontSize: '0.8rem' }}
                    onClick={() => removeItem(index)}
                  >
                    Remove
                  </button>
                </div>
              ))}
              {items.length === 0 && (
                <div style={{ 
                  color: '#6c757d', 
                  fontStyle: 'italic',
                  textAlign: 'center',
                  padding: '1rem'
                }}>
                  No items yet. Add some above!
                </div>
              )}
            </div>
          </div>
        </StateVisualizer>

        {/* Complex Nested State */}
        <StateVisualizer
          title="Complex Nested State"
          state={formData}
          actions={
            <>
              <button 
                className="button" 
                onClick={() => setFormData({
                  personal: { firstName: 'John', lastName: 'Doe' },
                  contact: { email: 'john@example.com', phone: '123-456-7890' },
                  preferences: { newsletter: true, notifications: false },
                })}
              >
                Fill Sample Data
              </button>
              <button 
                className="button secondary" 
                onClick={() => setFormData({
                  personal: { firstName: '', lastName: '' },
                  contact: { email: '', phone: '' },
                  preferences: { newsletter: false, notifications: true },
                })}
              >
                Reset Form
              </button>
            </>
          }
        >
          <div style={{ display: 'grid', gap: '1rem' }}>
            <fieldset style={{ border: '1px solid #dee2e6', borderRadius: '4px', padding: '1rem' }}>
              <legend style={{ fontWeight: 'bold', color: '#495057' }}>Personal Info</legend>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem' }}>
                <input
                  className="input"
                  type="text"
                  value={formData.personal.firstName}
                  onChange={(e) => updateFormData('personal', 'firstName', e.target.value)}
                  placeholder="First Name"
                />
                <input
                  className="input"
                  type="text"
                  value={formData.personal.lastName}
                  onChange={(e) => updateFormData('personal', 'lastName', e.target.value)}
                  placeholder="Last Name"
                />
              </div>
            </fieldset>
            
            <fieldset style={{ border: '1px solid #dee2e6', borderRadius: '4px', padding: '1rem' }}>
              <legend style={{ fontWeight: 'bold', color: '#495057' }}>Contact</legend>
              <div style={{ display: 'grid', gap: '0.5rem' }}>
                <input
                  className="input"
                  type="email"
                  value={formData.contact.email}
                  onChange={(e) => updateFormData('contact', 'email', e.target.value)}
                  placeholder="Email"
                />
                <input
                  className="input"
                  type="tel"
                  value={formData.contact.phone}
                  onChange={(e) => updateFormData('contact', 'phone', e.target.value)}
                  placeholder="Phone"
                />
              </div>
            </fieldset>
            
            <fieldset style={{ border: '1px solid #dee2e6', borderRadius: '4px', padding: '1rem' }}>
              <legend style={{ fontWeight: 'bold', color: '#495057' }}>Preferences</legend>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  <input
                    type="checkbox"
                    checked={formData.preferences.newsletter}
                    onChange={(e) => updateFormData('preferences', 'newsletter', e.target.checked)}
                  />
                  Subscribe to newsletter
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  <input
                    type="checkbox"
                    checked={formData.preferences.notifications}
                    onChange={(e) => updateFormData('preferences', 'notifications', e.target.checked)}
                  />
                  Enable notifications
                </label>
              </div>
            </fieldset>
          </div>
        </StateVisualizer>
      </div>

      <div className="card">
        <h2 style={{ color: '#2c3e50', marginBottom: '1rem' }}>
          💡 Key useState Concepts
        </h2>
        <div className="grid grid-2">
          <div>
            <h3 style={{ color: '#495057' }}>✅ Best Practices</h3>
            <ul style={{ paddingLeft: '1.5rem' }}>
              <li>Use functional updates for state that depends on previous state</li>
              <li>Keep state as simple as possible</li>
              <li>Use multiple useState calls for unrelated state</li>
              <li>Always create new objects/arrays instead of mutating</li>
            </ul>
          </div>
          <div>
            <h3 style={{ color: '#495057' }}>❌ Common Mistakes</h3>
            <ul style={{ paddingLeft: '1.5rem' }}>
              <li>Directly mutating state objects or arrays</li>
              <li>Forgetting that setState is asynchronous</li>
              <li>Using state for values that can be computed</li>
              <li>Not using the functional form when needed</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default UseStateDemo;
