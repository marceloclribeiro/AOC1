.data
    turno:                 .word 0
    array:                 .word -15, -15, -15, -15, -15, -15, -15, -15, -15
    linha:                 .asciiz  "   |   |   \n"  # index 1, 5, 9 sao modificados 
    separador:             .asciiz  "---+---+---\n"
    player1:               .byte  'x'
    player2:               .byte  'o'
    vazio:                 .byte  ' '
    insira_posicao:	   .asciiz  "Insira a posição:"
    print_jogodor1_ganhou: .asciiz  "\nX (xis) ganhou!\n"
    print_jogodor2_ganhou: .asciiz  "\nO (bolinha) ganhou!\n"
    print_empate:          .asciiz  "Empatou!\n"
    print_jogada_invalida: .asciiz  "\nJogada invalida! Jogue novamente...\n"
    print_bem_vindo:	   .asciiz  "Bem vindo ao Jogo da Velha!\n0.Iniciar\n1.Regras\n"
    print_regras:          .asciiz  "Para ganhar o jogo você deve ligar 3 de seus simbolos em sequência.Ex:\n x |   |   \n---+---+---\n x |   |   \n---+---+---\n x |   |   \n"
    print_posicoes:        .asciiz  "As posições são:\n 1 | 2 | 3 \n---+---+---\n 4 | 5 | 6 \n---+---+---\n 7 | 8 | 9 \n"
    print_novamente:       .asciiz  "Deseja jogar novamente?(N=0,S=1)\n"
    print_obrigado:        .asciiz  "Obrigado por jogar!\n"
.text
    main:
    	li $t8, 9
    	la   $a0, print_bem_vindo
        li   $v0, 4                   
        syscall
        li $t1,1
        li $v0, 5
        syscall
        beqz $v0,inicio
        beq $v0,$t1,regras
        j main
    regras:
    	la   $a0, print_regras
        li   $v0, 4
        syscall
        la   $a0, print_posicoes
        li   $v0, 4
        syscall
        
        j main
    inicio:
        jal print_jogo
        jal jogada
        j   verifica

    print_jogo:
        la $s2, array # i  = *array
        la $s0, linha # s0 = *linha
        li $s1, 1     # s1 = index
    desenho:
        lw   $t1, ($s2)         # t1 = array[i]
        bltz $t1, desenha_vazio # vazio     if t1 <  0
        bgtz $t1, desenha_o     # desenha_o if t1 >  0
        bgez $t1, desenha_x     # desenha_x if t1 >= 0
    desenha_o:
        lb  $t2, player2  # caracter = 'o'
        j next
    desenha_x:
        lb  $t2, player1  # caracter = 'x'
        j next
    desenha_vazio:
        lb  $t2, vazio    # caracter = ' '
        j next
    next:
        add $t1, $s0, $s1          # t1 = *linha[index]
        sb  $t2, ($t1)             # linha[index] = caracter
        addi $s2, $s2, 4           # i++
        addi $s1, $s1, 4           # index += 4
        li   $t1,13           # t1 = 13 (index 13 nao existe em linha)
        beq  $t1, $s1, print_linha # reset linha if s1 == 13 
        j desenho
    print_linha:
        la   $a0, linha                    # a0 = *linha
        li   $v0, 4                        # print
        syscall                            # string
        li   $s1, 1                        # index = 1 
        li   $t2, 36                       # array.length
        la   $t3, array                    # t3  = *array
        add  $t2, $t2, $t3                 # endereco array + 36 (9 words)
        beq  $s2, $t2, exit_print_desenho  # exit_print_desenho if i == fim do array
        la   $a0, separador                # a0 = *separador
        li   $v0, 4                        # print
        syscall                            # string
        j desenho
    exit_print_desenho:
        jr $ra

    jogada:
        la $a0, insira_posicao
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        move $s2, $v0

        la   $t0, array    # t0 = carrega endereco de array[0]
        li   $t5, 4        # t1 = 4 (tamanho da word no array)
        mult $s2,$t5
        mflo $s2
        
        li $s1, 0
        #add $s1, $t0, 40
        #sub $s1, $s1, $s2
        add  $s1,$s2,$t0
        addi $t1, $s1, -4
        lw   $t3, turno    # t3 = turno
        li   $t2, 2        # t2 = 2
        div  $t3, $t2      # turno / 2
        mfhi $t2           # t2 = turno % 2
        li   $t6, 1        # t6 = 1
        add  $t3, $t3, $t6 # t3 += 1
        beq  $t2, $zero, jogada_player_1 # se turno par jogador1 se impar jogador2 
        li   $t5, 1 # jogador2
        j verifica_jogada
    jogada_player_1:
        li   $t5, 0 # jogador1
    verifica_jogada:
        lw   $t6, ($t1)       
        bgez $t6, jogada_invalida # Branch on greater than or equal to zero(0 ou 1 já na posição)
        j store_jogada

    jogada_invalida:
        la  $a0, print_jogada_invalida
        li  $v0, 4
        syscall
        j jogada

    store_jogada:
        sw   $t3, turno    # turno++
        sw   $t5, ($t1)
        jr   $ra

    verifica:
    	
        la  $s5, array

	lw  $s0, 0($s5)       # 123     1xx
        lw  $s1, 16($s5)      # 456     x1x
        lw  $s2, 32($s5)      # 789     xx1 (0 + 4 + 8) = 3 || 0
        jal soma_ganha
        lw  $s0, 8($s5)       # 123     xx1
        lw  $s1, 16($s5)      # 456     x1x
        lw  $s2, 24($s5)      # 789     1xx (2 + 4 + 6) = 3 || 0
        jal soma_ganha
    
    
    



        lw  $s0, 0($s5)      # 123      111 
        lw  $s1, 4($s5)      # 456      xxx 
        lw  $s2, 8($s5)      # 789      xxx (0 + 1 + 2) = 3 || 0
        jal soma_ganha
        lw  $s0, 12($s5)     # 123      xxx 
        lw  $s1, 16($s5)     # 456      111 
        lw  $s2, 20($s5)     # 788      xxx (3 + 4 + 5) = 3 || 0
        jal soma_ganha
        lw  $s0, 24($s5)     # 123      xxx 
        lw  $s1, 28($s5)     # 456      xxx 
        lw  $s2, 32($s5)     # 789      111 (6 + 7 + 8) = 3 || 0
        jal soma_ganha
        lw  $s0, 0($s5)      # 123     1xx
        lw  $s1, 12($s5)     # 456     1xx
        lw  $s2, 24($s5)     # 789     1xx (0 + 3 + 6) = 3 || 0
        jal soma_ganha
        lw  $s0, 4($s5)       # 123     x1x
        lw  $s1, 16($s5)      # 456     x1x
        lw  $s2, 28($s5)      # 789     x1x (1 + 4 + 7) = 3 || 0
        jal soma_ganha
        lw  $s0, 8($s5)       # 123     xx1 
        lw  $s1, 20($s5)      # 456     xx1 
        lw  $s2, 32($s5)      # 789     xx1 (2 + 5 + 8) = 3 || 0
        jal soma_ganha
	
	addi $t8, $t8, -1
    	beqz $t8, empate
	
        j   inicio            # se não empatou nem ganhou continua o jogo

    soma_ganha:
        add $t1, $s0, $s1
        add $t1, $t1, $s2
        li  $t2, 3
        beq $t1, $t2,   jogodor2_ganhou
        beq $t1, $zero, jogodor1_ganhou
        jr  $ra
    jogodor1_ganhou:
        jal print_jogo
        la  $a0, print_jogodor1_ganhou
        li  $v0, 4
        syscall
        j   novamente
    jogodor2_ganhou:
        jal print_jogo
        la  $a0, print_jogodor2_ganhou
        li  $v0, 4
        syscall
        j   novamente
    empate:
    	jal print_jogo
        la $a0, print_empate
        li $v0, 4
        syscall
        j novamente


novamente:
	la $a0, print_novamente
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	beqz $v0, exit
	li $t1, 1
	beq $v0, $t1, again
	#beqz $v0, exit
	j novamente
again:	la $s2, array
	li $t1, -15
	li $t2, 9
loop:	sw $t1, 0($s2)
	add $s2, $s2, 4
	addi $t2, $t2, -1
	beqz $t2, main
	j loop
    exit:
	la $a0, print_obrigado
	li $v0, 4
	syscall
        li  $v0, 10
        syscall
