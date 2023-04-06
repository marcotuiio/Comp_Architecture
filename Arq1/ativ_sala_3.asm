.text
	.macro terminate
		addi $v0, $zero, 10  # Encerrando o programa
		syscall
	.end_macro

	## PRINTS
	.macro print_int(%x)
		add $a0, %x, $zero  # Carregando $a0 com int %x a printar
		addi $v0, $zero, 1  # Informando que o syscall deve printar int
		syscall
	.end_macro
	
	.macro print_str(%str)
		.data
			toPrint: .asciiz %str
		.text	
		la $a0, toPrint  # Carregando em $a0 a string a printar (Separador)
		addi $v0, $zero, 4  # Informando que o syscall deve printar string
		syscall
	.end_macro

	.macro scan_int(%a)
		addi $v0, $zero, 5  # Informando que o syscall deverá ler um int
		syscall
		add %a, $v0, $zero  # Armazenando A em $s0
	.end_macro

main:
	print_str("Informe um número inteiro positivo para saber se é inteiro perfeito: \n")
	print_str("N = ")
	scan_int($s0)  # Lendo inteiro e armazendo em $s0 via macro
	print_str("\n")
		
	positivo:
		slt $t0, $zero, $s0  # Se $zero menor que $s0, $t0 = 1, logo $s0 positivo diferente de 0
		beq $t0, 0, error  # Se $t0 = 0, número em $s0 negativo e vai sair para erro
	
	li $s5, 0  # Load inicial de $s5 com 0, armazenará a soma dos divisores 
	li $s1, 1  # Load inicial de divisores 
	# Obs: poderia começar $s5 em 1 e $s1 em 2 pois 1 é divisor universal, porém por 
	# motivos de estética optei por começar dos valores padrões
	loop: 
		beq $s1, $s0, result
		div $s0, $s1  # Dividindo $s0 por $s1 e assim o qouciente estará em LO e o resto em HI
		mfhi $t1  # Recuperando resto da divisão e armaenando em $t1
		bne $t1, $zero, repetir  # Se resto for zero, devo acumalar, senão preparar para repetir loop
		print_int($s1)
		print_str(" + ")
		add $s5, $s5, $s1
								
		repetir:  # Preparação padrão para repetir loop
			add $s1, $s1, 1  # Somando mais 1 no divisor $s1
			j loop  # repetindo loop
			
	result:
		print_str("\nSOMA = ")
		print_int($s5)
		print_str("\nN ")
		print_int($s0)
		bne $s5, $s0, nope  # Se soma não for igual ao número passado, não é
		
		print_str(" É um número perfeito\n")
		terminate  # Encerrando
		nope: 
			print_str(" NÃO é um número perfeito\n")
		
		terminate  # Encerrando
			
	error:
		print_str("\nApenas números positivos, tente novamente\n")
		terminate  # Encerrando