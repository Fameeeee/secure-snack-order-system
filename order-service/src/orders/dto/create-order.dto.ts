import { IsString, IsInt, Min, MaxLength, IsNotEmpty } from 'class-validator';

export class CreateOrderDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  customerName: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  snackName: string;

  @IsInt()
  @Min(1, { message: 'สั่งขนมต้องสั่งอย่างน้อย 1 ชิ้นสิโว้ย!' }) // Custom error message
  quantity: number;
}