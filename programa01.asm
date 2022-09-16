## Percorrer vetor e somar, separadamente, elementos positivos e negativos 

.data
	vetor: .word -2, 4, 7, -3, 0, -3, 5, 6  # Declarando vetor 
	size: 8  # Declarando tamanho do vetor
.word
	strP: .asciiz "A soma dos valores positivos = "  # Declarando string da saída
	strN: .asciiz "\nA soma dos valores negativos = "  # Declarando string da saída		
.text
	
main: 
	lw $s5, size  # Carregando em $s5 o tamanho do vetor
	la $s6, vetor  # Carregando em $s6 o endereço do vetor
	add $s3, $zero, $zero  # Carregando indice i=0 do vetor em $s3
	loop: 
		beq $s3, $s5, exit  # Se tamanho máximo do vetor ja foi alcaçando, encerrar
		sll $t1, $s3, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
		add $t1, $t1, $s6  # Carregando em $t1 = endereço de vetor[i] 
		lw $t0, 0($t1)  # $t0 = valor de vetor[i]
		slt	$t2, $zero, $t0  # Se zero é menor que $t0, numero positivo ($t2=1)
		bne $t2, 1, else  # Se $t2 = 1, numero é positivo então somar na variavel dos positivos	
		add $s0, $s0, $t0  # $s0 recebendo a soma dos elementos positivos
		j iterar  # Indo para trecho de atualizar loop
		else: # Se t2 != 1, então número em $t0 é negativo
			add $s1, $s1, $t0  # $s1 recebendo a soma dos elementos negativos
		iterar:
			addi $s3, $s3, 1  # atualizando indice do vetor i=i+1 em $s3
			j loop  # Repetindo loop 
	exit:
		la $a0, strP  # Carregando em $a0 a string a printar
		addi $v0, $zero, 4  # Informando que o syscall deve printar string
		syscall
		add $a0, $s0, $zero  # Carregando $a0 com a soma dos positivos
		addi $v0, $zero, 1  # Informando que o syscall deve printar int
		syscall  
		la $a0, strN  # Carregando em $a0 a string a printar
		addi $v0, $zero, 4  # Informando que o syscall deve printar string
		syscall
		add $a0, $s1, $zero  # Carregando $a0 com a soma dos negativos
		addi $v0, $zero, 1  # Informando que o syscall deve printar int
		syscall
		addi $v0, $zero, 10  # Encerrando o programa
		syscall
		
		
		
