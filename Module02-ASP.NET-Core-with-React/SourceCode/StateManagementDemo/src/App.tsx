import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AppProvider } from './context/AppContext';
import { CounterProvider } from './context/CounterContext';
import Layout from './components/Layout';
import Home from './pages/Home';
import UseStateDemo from './pages/UseStateDemo';
import UseEffectDemo from './pages/UseEffectDemo';
import ContextDemo from './pages/ContextDemo';
import UseReducerDemo from './pages/UseReducerDemo';
import CustomHooksDemo from './pages/CustomHooksDemo';
import PropDrillingDemo from './pages/PropDrillingDemo';

function App() {
  return (
    <AppProvider>
      <CounterProvider>
        <Router>
          <Layout>
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/usestate" element={<UseStateDemo />} />
              <Route path="/useeffect" element={<UseEffectDemo />} />
              <Route path="/context" element={<ContextDemo />} />
              <Route path="/usereducer" element={<UseReducerDemo />} />
              <Route path="/custom-hooks" element={<CustomHooksDemo />} />
              <Route path="/prop-drilling" element={<PropDrillingDemo />} />
            </Routes>
          </Layout>
        </Router>
      </CounterProvider>
    </AppProvider>
  );
}

export default App;
