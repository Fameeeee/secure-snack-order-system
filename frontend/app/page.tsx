'use client';
import { useEffect, useState } from 'react';

export default function Home() {
  const [orders, setOrders] = useState([]);
  const [form, setForm] = useState({ customerName: '', snackName: '', quantity: 1 });
  const API_URL = 'http://localhost:3000/orders'; // ยิงผ่าน Port-forward

  const fetchOrders = () => {
    fetch(API_URL).then(res => res.json()).then(setOrders);
  };

  useEffect(fetchOrders, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form),
    });
    setForm({ customerName: '', snackName: '', quantity: 1 });
    fetchOrders();
  };

  const deleteOrder = async (id: string) => {
    await fetch(`${API_URL}/${id}`, { method: 'DELETE' });
    fetchOrders();
  };

  return (
    <main className="p-10 max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-8">จัดการออเดอร์ร้านขนมเอิร์น 🍪</h1>
      
      {/* Form สร้างออเดอร์ */}
      <form onSubmit={handleSubmit} className="mb-10 p-6 bg-gray-50 rounded-lg shadow">
        <div className="grid grid-cols-3 gap-4">
          <input className="border p-2" placeholder="ชื่อลูกค้า" value={form.customerName} onChange={e => setForm({...form, customerName: e.target.value})} required />
          <input className="border p-2" placeholder="ชื่อขนม" value={form.snackName} onChange={e => setForm({...form, snackName: e.target.value})} required />
          <input className="border p-2" type="number" value={form.quantity} onChange={e => setForm({...form, quantity: Number(e.target.value)})} required />
        </div>
        <button type="submit" className="mt-4 bg-orange-500 text-white px-6 py-2 rounded hover:bg-orange-600">เพิ่มออเดอร์</button>
      </form>

      {/* รายการออเดอร์ */}
      <div className="space-y-4">
        {orders.map((order: any) => (
          <div key={order.id} className="flex justify-between items-center p-4 border rounded shadow-sm bg-white">
            <div>
              <p className="font-bold">{order.customerName}</p>
              <p className="text-sm text-gray-600">{order.snackName} x {order.quantity}</p>
            </div>
            <button onClick={() => deleteOrder(order.id)} className="text-red-500 hover:underline">ลบ</button>
          </div>
        ))}
      </div>
    </main>
  );
}