.include "macros.asm"

.data
	zeroFloat: .float 0.0	
	pi: .float 3.14159265
	divi: .float 180.0
	
.text
	main:
		print_str("\nInforme a quantidade N de termos da série para utilizar na aproximação: ")
		scan_int($s1)
		print_str("Informe um angulo X, em graus, para calcular uma aproximação do cos(X): ")
		scan_float($f1)
		mov.s $f8, $f1
		
		## A aproximacao do cosseno funciona apenas para graus em radianos, portanto,
		## por conveniencia, adicionei uma funcao para converter os graus pro conta propria
		lwc1 $f0, pi
		mul.s $f1, $f1, $f0
		lwc1 $f0, divi
		div.s $f1, $f1, $f0
		
		li $s2, 0 # Contador da qntd de termos
		li $s3, 0 # Sera utilizado nas potencias e nos fatoriais (ambos disponiveis em macros)
		li $t9, 2
		lwc1 $f9, zeroFloat 
		aprox:
			beq $s2, $s1, end
			potencia($f1, $s3, $f4) # valor em f1 elevado a s3, resultado em f4
			fatorial($s3, $s4) # fatorial de s3 com valor armazenado em s4
			mtc1 $s4, $f5
			cvt.s.w $f5, $f5
			div.s $f6, $f4, $f5 # divisao do resultado da potencia pelo fatorial
			div $s2, $t9
			mfhi $s4 
			beq $s4, $zero, positivo
			negativo:
				sub.s $f9, $f9, $f6
				j padrao
			positivo:
				add.s $f9, $f9, $f6
			padrao:
				addi $s3, $s3, 2
				addi $s2, $s2, 1
				j aprox
		end:
		
		print_str("\n Valor aproximado para cos(")
		print_float($f8)
		print_str(") = ")
		print_float($f9)
		
		terminate