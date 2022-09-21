## Armazenar em um vetor squares[64s] o produto de i*i, percorrendo-o 
## até um limite N informado pelo usuário. Após carregar o vetor,
## percorrer todas suas posições somando os elementos e ao final,
## exibir essa soma para o usuário

.data
	squares: .space 256  # Reservando espaço para armazenar 64 (64*4=256) inteiros no vetor 
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
	print_str("\nInforme um número positivo entre 1 e 64:\nN = ")
	scan_int($s0)  # Armazenando número informando em $s0
	
	li $s4, 64 
	positivo:
		slt $t0, $zero, $s0  # Se $zero menor que $s0, $t0 = 1, logo $s0 positivo diferente de 0
		beq $t0, 0, error  # Se $t0 = 0, número em $s0 negativo e vai sair para erro
	maior:
		sgt $t0, $s0, $s4  # Analisando se $s0 está além do limite de 64 posições do vetor
		beq $t0, 1, error  # Se $t0 = 1, numéro é maior que 64

	li $s1, 0  # Carregando em $s1 iterador i=0
	li $s3, 0  # Carregando em $s3 iterador extra i=0
	la $s5, squares  # Carregando em $s5 endereço do vetor squares
	li $s6, 0  # Carregando em $s6 resultado soma=0
	
	print_str("VETOR: \n")
	store_values:
		beq $s1, $s0, compute_sum  # Se tamanho máximo do vetor ja foi alcaçando, encerrar
		sll $t1, $s1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
		add $t1, $t1, $s5  # Carregando em $t1 = endereço de vetor[i] 
		mul $t2, $s1, $s1  # Realizando multiplicação de i*i e armazenando em $s2 
		sw $t2, 0($t1)  # Armazenando valor de $s2 na posição $t1 do vetor squares
		print_int($t2)
		print_str(" | ")
		addi $s1, $s1, 1  # Atualizando i = i+1
		j store_values  # Repetindo loop de carregar valores
	
	compute_sum:
		beq $s3, $s0, exit  # Se tamanho máximo do vetor ja foi alcaçando, encerrar
		sll $t1, $s3, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
		add $t1, $t1, $s5  # Carregando em $t1 = endereço de vetor[i] 
		lw $t2, 0($t1)  # $t2 = valor de vetor[i]
		add $s6, $s6, $t2  # Amazenando em  $s6 a soma dos elementos do vetor
		addi $s3, $s3, 1  # Atualizando i = i+1
		j compute_sum
		
	exit:
		print_str("\n\nSOMA = ")
		print_int($s6)
		terminate
	
	error:
		print_str("\nApenas números entre 1 e 64, tente novamente\n")
		terminate  # Encerrando
