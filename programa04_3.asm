.include "macros.asm"

.text

main:
	print_str("\nArranjo Simples, da Análise Combinatória\n 	n!/(n-p)!")
	print_str("\n\nInforme um número N = ")
	scan_int($s0)
	print_str("\nInforme um número P = ")
	scan_int($s1)
	
	ifs:
		beq $s0, $s1, continua # Se N = P, não teremos problemas
		sgt $t0, $s0, $s1  # Se N > P, $t0 = 1 e tudo está certo
		beq $t0, $zero, erro  # Se N < P, $t0 = 0 e não pedemos ter fatorial de negativos 
		
	continua:
		fatorial($s0, $s2)  # Em $s2 estará o resultado de n! após a execução da macro
		sub $s3, $s0, $s1  # Armazenando em $s3 = n - p
		fatorial($s3, $s4)  # Em $s4 estará o resultado de (n - p)! após a execução da macro
		div $s2, $s4  # Dividindo n! por (n-p)!
		mflo $t1  # quociente da divisão está agora em $t1
		mfhi $t2  # resto da divisão está agora em $t2 
		
		print_str("\nRESULTADO = ")
		print_int($t1)
		print_str(", ")
		print_int($t2)
		terminate
	
	erro:
		print_str("\nN deve ser maior que P, tente novamente\n")
		terminate
