import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productApi } from '../services/api';
import { Product } from '../types/Product';
import ProductForm from './ProductForm';
import './ProductList.css';

const ProductList: React.FC = () => {
  const queryClient = useQueryClient();
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [filters, setFilters] = useState({
    category: '',
    minPrice: '',
    maxPrice: '',
    pageNumber: 1,
    pageSize: 10,
  });

  // Fetch products
  const { data, isLoading, error } = useQuery({
    queryKey: ['products', filters],
    queryFn: () => productApi.getProducts({
      category: filters.category || undefined,
      minPrice: filters.minPrice ? Number(filters.minPrice) : undefined,
      maxPrice: filters.maxPrice ? Number(filters.maxPrice) : undefined,
      pageNumber: filters.pageNumber,
      pageSize: filters.pageSize,
    }),
  });

  // Fetch categories
  const { data: categories } = useQuery({
    queryKey: ['categories'],
    queryFn: productApi.getCategories,
  });

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: productApi.deleteProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    },
  });

  const handleEdit = (product: Product) => {
    setEditingProduct(product);
    setShowAddForm(false);
  };

  const handleDelete = async (id: number) => {
    if (window.confirm('Are you sure you want to delete this product?')) {
      deleteMutation.mutate(id);
    }
  };

  const handleCloseForm = () => {
    setEditingProduct(null);
    setShowAddForm(false);
  };

  const handleFilterChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFilters(prev => ({ ...prev, [name]: value, pageNumber: 1 }));
  };

  const handlePageChange = (page: number) => {
    setFilters(prev => ({ ...prev, pageNumber: page }));
  };

  if (isLoading) return <div className="loading">Loading products...</div>;
  if (error) return <div className="error">Error loading products: {(error as Error).message}</div>;

  return (
    <div className="product-list-container">
      <h1>Product Management</h1>
      
      <div className="filters">
        <select 
          name="category" 
          value={filters.category} 
          onChange={handleFilterChange}
          className="filter-select"
        >
          <option value="">All Categories</option>
          {categories?.map(cat => (
            <option key={cat} value={cat}>{cat}</option>
          ))}
        </select>
        
        <input
          type="number"
          name="minPrice"
          placeholder="Min Price"
          value={filters.minPrice}
          onChange={handleFilterChange}
          className="filter-input"
        />
        
        <input
          type="number"
          name="maxPrice"
          placeholder="Max Price"
          value={filters.maxPrice}
          onChange={handleFilterChange}
          className="filter-input"
        />
        
        <button 
          onClick={() => setShowAddForm(true)} 
          className="btn btn-primary"
        >
          Add New Product
        </button>
      </div>

      {(showAddForm || editingProduct) && (
        <ProductForm
          product={editingProduct}
          onClose={handleCloseForm}
          onSuccess={() => {
            handleCloseForm();
            queryClient.invalidateQueries({ queryKey: ['products'] });
          }}
        />
      )}

      <div className="product-grid">
        {data?.data.map(product => (
          <div key={product.id} className="product-card">
            <h3>{product.name}</h3>
            <p className="description">{product.description}</p>
            <p className="category">{product.category}</p>
            <p className="price">${product.price.toFixed(2)}</p>
            <p className="stock">Stock: {product.stockQuantity}</p>
            <p className={`status ${product.isActive ? 'active' : 'inactive'}`}>
              {product.isActive ? 'Active' : 'Inactive'}
            </p>
            <div className="actions">
              <button onClick={() => handleEdit(product)} className="btn btn-edit">
                Edit
              </button>
              <button 
                onClick={() => handleDelete(product.id)} 
                className="btn btn-delete"
                disabled={deleteMutation.isPending}
              >
                Delete
              </button>
            </div>
          </div>
        ))}
      </div>

      {data && (
        <div className="pagination">
          <button 
            onClick={() => handlePageChange(data.pageNumber - 1)}
            disabled={!data.hasPreviousPage}
            className="btn"
          >
            Previous
          </button>
          <span>Page {data.pageNumber} of {data.totalPages}</span>
          <button 
            onClick={() => handlePageChange(data.pageNumber + 1)}
            disabled={!data.hasNextPage}
            className="btn"
          >
            Next
          </button>
        </div>
      )}
    </div>
  );
};

export default ProductList;