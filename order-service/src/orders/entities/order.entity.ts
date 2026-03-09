import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('orders') 
export class Order {
  @PrimaryGeneratedColumn('uuid') 
  id: string;

  @Column({ length: 100 })
  customerName: string;

  @Column({ length: 50 })
  snackName: string;

  @Column('int')
  quantity: number;

  @CreateDateColumn()
  createdAt: Date;
}