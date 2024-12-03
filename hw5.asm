.data
space: .asciiz " "    # Space character for printing between numbers
newline: .asciiz "\n" # Newline character
extra_newline: .asciiz "\n\n" # Extra newline at end

.text
.globl zeroOut 
.globl place_tile 
.globl printBoard 
.globl placePieceOnBoard 
.globl test_fit 

______________________________________________________________________________________________________________________________________________________________________
# Function: zeroOut
# Arguments: None
# Returns: void
zeroOut:
    # Function prologue
    addiu $sp, $sp, -8 
    sw $ra, 4($sp)

    # Initialize variables
    la $t0, board           # Load address of board
    lw $t1, board_width     # Load number of columns
    lw $t2, board_height    # Load number of rows
    li $t3, 0               # index = 0

zeroOut_outer: 
    bge $t3, $t2, zero_done # if row index >= board_height, exit outer loop
    li $t4, 0               # column index = 0

zeroOut_inner: 
    bge $t4, $t1, next_row      # If all columns are done, go next row
    mul $t5, $t3, $t1           # row offset = row index * number of columns
    add $t6, $t5, $t4           # array index = row offset + column index
    add $t7, $t0, $t6           # memory address of board element
    lb $a0, 0($t7)              # Load current board element
    # Set board[index] to 0

    addiu $t4, $t4, 1           # column index + 1
    j zeroOut_inner          # Jump back to process the next column

next_row:
zero_done:
    # Function epilogue
    jr $ra
______________________________________________________________________________________________________________________________________________________________________
# Function: placePieceOnBoard
# Arguments: 
#   $a0 - address of piece struct
#   $a1 - ship_num
placePieceOnBoard:
    # Function prologue

    # Load piece fields
    # First switch on type
    li $t0, 1
    beq $s3, $t0, piece_square
    li $t0, 2
    beq $s3, $t0, piece_line
    li $t0, 3
    beq $s3, $t0, piece_reverse_z
    li $t0, 4
    beq $s3, $t0, piece_L
    li $t0, 5
    beq $s3, $t0, piece_z
    li $t0, 6
    beq $s3, $t0, piece_reverse_L
    li $t0, 7
    beq $s3, $t0, piece_T
    j piece_done       # Invalid type

piece_done:
    jr $ra


______________________________________________________________________________________________________________________________________________________________________
# Function: printBoard
# Arguments: None (uses global variables)
# Returns: void
# Uses global variables: board (char[]), board_width (int), board_height (int)

printBoard:
    # Function prologue
    addiu $sp, $sp, -8      # Allocate stack space
    sw $ra, 4($sp)          # Save return address

    #Initialize variables
    la $t0, board           # Load address of board
    lw $t1, board_width     # Load number of columns
    lw $t2, board_height    # Load number of rows
    li $t3, 0               # row index = 0

printBoard_outer:
    bge $t3, $t2, done      # if row index >= board_height, exit outer loop
    li $t4, 0               # column index = 0

printBoard_inner:
    mul $t5, $t3, $t1       # row offset = row index * number of columns
    add $t6, $t5, $t4       # array index = row offset + column index
    add $t7, $t0, $t6       # memory address of board element
    lb $a0, 0($t7)          # Load current board element
    li $v0, 11              # Set syscall code for printing character
    addi $a0, $a0, '0'      # Convert number to ASCII character
    syscall                 # Print character
    li $v0, 11              # Set syscall code for printing space
    syscall                 # Print the space

    addiu $t4, $t4, 1       # column index + 1
    j printBoard_inner      # Jump back to process the next column

printBoard next_row:
    li $v0, 11              # Set syscall code for printing newline
    li $a0, '\n'            # Load newline character
    syscall                 # Print the space
    addiu $t3, $t3, 1       # Increment row index
    j printBoard_outer      # Jump back to process the next row

done:
    # Function epilogue
    lw $ra, 4($sp)          # Restore return address
    addiu $sp, $sp, 8       # Deallocate Stack Space
    jr $ra                  # Return
______________________________________________________________________________________________________________________________________________________________________

# Function: place_tile
# Arguments: 
#   $a0 - row
#   $a1 - col
#   $a2 - value
# Returns:
#   $v0 - 0 if successful, 1 if occupied, 2 if out of bounds
# Uses global variables: board (char[]), board_width (int), board_height (int)

place_tile:
    jr $ra
______________________________________________________________________________________________________________________________________________________________________
# Function: test_fit
# Arguments: 
#   $a0 - address of piece array (5 pieces)
test_fit:
    # Function prologue
    jr $ra


T_orientation4:
    # Study the other T orientations in skeleton.asm to understand how to write this label/subroutine
    j piece_done

.include "skeleton.asm"