## Ler A e B, positivos
## Imprimir os múltiplos de A no intervalo [A, AxB]

.data
	erro: .asciiz "Apenas números positivos, tente novamente\n"
	msg: .asciiz "-- Múltiplos no intervalo [A,AxB] --\n\n"
	spt: .asciiz " | " 
.text

main:
	addi $v0, $zero, 5  # Informando que o syscall deverá ler um int
	syscall
	add $s0, $v0, $zero  # Armazenando A em $s0	
	addi $v0, $zero, 5  # Informando que o syscall deverá ler um int
	syscall
	add $s1, $v0, $zero  # Armazenando b em $s1
	
	positivoA:
		slt $t0, $zero, $s0  # Se $zero menor que $s0, $t0 = 1, logo $s0 positivo diferente de 0
		beq $t0, $zero, error  # Se $t0 = 0, número em $s0 negativo e vai sair para erro
	positivoB:
		slt $t0, 1, $s1  # Se $zero menor que $s1, $t0 = 1, logo $s1 positivo diferente de 0
		beq $t0, 0, error  # Se $t0 = 0, número em $s0 negativo e vai sair para erro
		
		la $a0, msg  # Carregando em $a0 a string a printar (Mensagenzinha)
		addi $v0, $zero, 4  # Informando que o syscall deve printar string
		syscall
	        
                add $s2, $zero, $s0  # Carregando em $s2 o valor inicial de A ($s0)
                mul $s2, $s0, $s1  # Copiando para $s2 o valor de AxB ($s0x$s1)
                add $s3, $t2, $zero  # Armazenando definitivo em $s2 o limite do intervalo ($t2)

		loop:  # Loop para printar múltiplos de A no intervalo
			sgt $t1, $s2, $s3  # Comparando se valor atual de $s2 é maior que B
			beq $t1, 1, exit  # Se $t1 = 1, então o intervalo todo de A-B ja foi percorrido
			add $a0, $s2, $zero  # Carregando $a0 com o múltiplo atual de A
			addi $v0, $zero, 1  # Informando que o syscall deve printar int
			syscall 
			la $a0, spt  # Carregando em $a0 a string a printar (Separador)
			addi $v0, $zero, 4  # Informando que o syscall deve printar string
			syscall
			add $s2, $s2, $s0  # Atualizando $s2 para o próximo múltiplo de A somando o próprio A
			j loop  # Repetindo o loop
	
	error: 
		la $a0, erro  # Carregando em $a0 a string a printar (Erro)
		addi $v0, $zero, 4  # Informando que o syscall deve printar string
		syscall
	exit:
		addi $v0, $zero, 10  # Encerrando o programa
		syscall
