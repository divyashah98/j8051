/* 
 * Copyright (c) 2014, Dries007
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 *  Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 *  Neither the name of the project nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 */
package net.dries007.j8051.gui;

import java.io.*;
import javax.swing.text.Segment;

import org.fife.ui.rsyntaxtextarea.*;


/**
 *
 * 2014/12/03
 *
 * Assembler8051TokenMaker.java - An object that can take a chunk of text and return a linked list of tokens representing 8051 assembler.
 *
 * This file was made for the project <a href="https://github.com/dries007/j8051">j8051</a>, and is specifically tailored towards the XC888 from Infineon
 * This file was made by modifying "Assembler8051TokenMaker", and uses the register list of an include file made by a teacher of mine (Roggemans M. aka MGM).
 *
 * This implementation was created using <a href="http://www.jflex.de/">JFlex</a> 1.4.1; 
 * however, the generated file was modified for performance.
 * Memory allocation needs to be almost completely removed to be competitive with the handwritten lexers 
 *(subclasses of <code>AbstractTokenMaker</code>, so this class has been modified so that Strings are never allocated (via yytext()), 
 * and the scanner never has to worry about refilling its buffer (needlessly copying chars around).
 * We can achieve this because RText always scans exactly 1 line of tokens at a time, and hands the scanner this line as an array of characters (a Segment really).
 * Since tokens contain pointers to char arrays instead of Strings holding their contents, there is no need for allocating new memory for Strings.<p>
 *
 * The actual algorithm generated for scanning has, of course, not been modified.<p>
 *
 * If you wish to regenerate this file yourself, keep in mind the following:
 * <ul>
 *   <li>The generated Assembler8051TokenMaker.java</code> file will contain two
 *       definitions of both <code>zzRefill</code> and <code>yyreset</code>.
 *       You should hand-delete the second of each definition (the ones
 *       generated by the lexer), as these generated methods modify the input
 *       buffer, which we'll never have to do.</li>
 *   <li>You should also change the declaration/definition of zzBuffer to NOT
 *       be initialized.  This is a needless memory allocation for us since we
 *       will be pointing the array somewhere else anyway.</li>
 *   <li>You should NOT call <code>yylex()</code> on the generated scanner
 *       directly; rather, you should use <code>getTokenList</code> as you would
 *       with any other <code>TokenMaker</code> instance.</li>
 * </ul>
 *
 * I, Dries007, hereby grant the author of the RSyntaxTextArea library (Robert Futrell) the right to include this file into his library, even with changed licence header, provided that the following conditions are met:
 * -    I must be credited as creator of this file.
 * -    As long as the registers list is not rewritten to remove XC888 specific entries, 'Roggemans M. aka MGM' must be credited for the list.
 *
 * @author Dries007
 * @version 0.1
 */
%%

%public
%class Assembler8051TokenMaker
%extends AbstractJFlexTokenMaker
%unicode
%ignorecase
%type org.fife.ui.rsyntaxtextarea.Token


%{


	/**
	 * Constructor.  We must have this here as JFLex does not generate a
	 * no parameter constructor.
	 */
	public Assembler8051TokenMaker() {
		super();
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 */
	private void addToken(int tokenType) {
		addToken(zzStartRead, zzMarkedPos-1, tokenType);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 */
	private void addToken(int start, int end, int tokenType) {
		int so = start + offsetShift;
		addToken(zzBuffer, start,end, tokenType, so);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param array The character array.
	 * @param start The starting offset in the array.
	 * @param end The ending offset in the array.
	 * @param tokenType The token's type.
	 * @param startOffset The offset in the document at which this token
	 *                    occurs.
	 */
	@Override
	public void addToken(char[] array, int start, int end, int tokenType, int startOffset) {
		super.addToken(array, start,end, tokenType, startOffset);
		zzStartRead = zzMarkedPos;
	}


	/**
	 * {@inheritDoc}
	 */
	@Override
	public String[] getLineCommentStartAndEnd(int languageIndex) {
		return new String[] { ";", null };
	}


	/**
	 * Returns the first token in the linked list of tokens generated
	 * from <code>text</code>.  This method must be implemented by
	 * subclasses so they can correctly implement syntax highlighting.
	 *
	 * @param text The text from which to get tokens.
	 * @param initialTokenType The token type we should start with.
	 * @param startOffset The offset into the document at which
	 *                    <code>text</code> starts.
	 * @return The first <code>Token</code> in a linked list representing
	 *         the syntax highlighted text.
	 */
	public Token getTokenList(Segment text, int initialTokenType, int startOffset) {

		resetTokenList();
		this.offsetShift = -text.offset + startOffset;

		// Start off in the proper state.
		int state = Token.NULL;
		switch (initialTokenType) {
			default:
				state = Token.NULL;
		}

		s = text;
		try {
			yyreset(zzReader);
			yybegin(state);
			return yylex();
		} catch (IOException ioe) {
			ioe.printStackTrace();
			return new TokenImpl();
		}

	}


	/**
	 * Refills the input buffer.
	 *
	 * @return      <code>true</code> if EOF was reached, otherwise
	 *              <code>false</code>.
	 * @exception   IOException  if any I/O-Error occurs.
	 */
	private boolean zzRefill() throws java.io.IOException {
		return zzCurrentPos>=s.offset+s.count;
	}


	/**
	 * Resets the scanner to read from a new input stream.
	 * Does not close the old reader.
	 *
	 * All internal variables are reset, the old input stream 
	 * <b>cannot</b> be reused (internal buffer is discarded and lost).
	 * Lexical state is set to <tt>YY_INITIAL</tt>.
	 *
	 * @param reader   the new input stream 
	 */
	public final void yyreset(java.io.Reader reader) throws java.io.IOException {
		// 's' has been updated.
		zzBuffer = s.array;
		/*
		 * We replaced the line below with the two below it because zzRefill
		 * no longer "refills" the buffer (since the way we do it, it's always
		 * "full" the first time through, since it points to the segment's
		 * array).  So, we assign zzEndRead here.
		 */
		//zzStartRead = zzEndRead = s.offset;
		zzStartRead = s.offset;
		zzEndRead = zzStartRead + s.count - 1;
		zzCurrentPos = zzMarkedPos = zzPushbackPos = s.offset;
		zzLexicalState = YYINITIAL;
		zzReader = reader;
		zzAtBOL  = true;
		zzAtEOF  = false;
	}


%}

Letter				= ([A-Za-z_])
Digit				= ([0-9])
Dec				    = ({Digit}+)
Hex				    = ([0-9A-Fa-f]+[hH])
Bin				    = ([01]+[bB])
Oct                 = ([0-7]+[oOqQ])

Number				= ({Dec}|{Hex}|{Bin}|{Oct})

Identifier			= (({Letter}|{Digit})[^ \t\f\n\,\.\+\-\*\/\%\[\]]+)

UnclosedStringLiteral	= ([\"][^\"]*)
StringLiteral			= ({UnclosedStringLiteral}[\"])
UnclosedCharLiteral		= ([\'][^\']*)
CharLiteral			= ({UnclosedCharLiteral}[\'])

CommentBegin			= ([;])

LineTerminator			= (\n)
WhiteSpace			= ([ \t\f])

Label				= (({Letter}|{Digit})+[\:])

Operator				= ("+"|"-"|"*"|"/"|"%"|"^"|"|"|"&"|"~"|"!"|"="|"<"|">")

%%

<YYINITIAL> {

	/* Keywords */
	"#include\s+\".*\"" |
	"#include\s+\<.*\>" |
	"#define" |
	"#ifdef" |
	"#ifndef" |
	"#else" |
	"#endif"		{ addToken(Token.PREPROCESSOR); }

    /* functions or compiler directives */
    
	"LOW" |
	"HIGH" |
	"EQU" |
	"DB" |
	"DW" |
	"DS" |
	"DBIT" |
	"AT" |
	"ORG" |
	"END" |
	"CSEG" |
	"XSEG" |
	"DSEG" |
	"BSEG" |
	"CODE" |
	"XDATA" |
	"DATA" |
	"IDATA" |
	"BIT" |
	"RSEG"		{ addToken(Token.FUNCTION); }

	/* Registers, list by Roggemans M. aka MGM */
	    "sp" |
	"dpl" |
	"dph" |
	"pcon" |
	"tcon" |
	"tf1" |
	"tr1" |
	"tf0" |
	"tr0" |
	"ie1" |
	"it1" |
	"ie0" |
	"it0" |
	"tmod" |
	"tl0" |
	"tl1" |
	"th0" |
	"th1" |
	"syscon0" |
	"scon" |
	"sm0" |
	"sm1" |
	"sm2" |
	"ren" |
	"tb8" |
	"rb8" |
	"ti" |
	"ri" |
	"sbuf" |
	"eo" |
	"ien0" |
	"ea" |
	"et2" |
	"es" |
	"et1" |
	"ex1" |
	"et0" |
	"ex0" |
	"ip" |
	"pt2" |
	"ps" |
	"pt1" |
	"px1" |
	"pt0" |
	"px0" |
	"iph" |
	"psw" |
	"cy" |
	"ac" |
	"f0" |
	"rs1" |
	"rs0" |
	"ov" |
	"f1" |
	"p" |
	"acc" |
	"ien1" |
	"eccip3" |
	"eccip2" |
	"eccip1" |
	"eccip0" |
	"exm" |
	"ex2" |
	"essc" |
	"eadc" |
	"b" |
	"ip1" |
	"pccip3" |
	"pccip2" |
	"pccip1" |
	"pccip0" |
	"pxm" |
	"px2" |
	"pssc" |
	"padc" |
	"iph1" |
	"scu_page" |
	"modpisel" |
	"ircon0" |
	"ircon1" |
	"ircon2" |
	"exicon0" |
	"exicon1" |
	"nmicon" |
	"nmisr" |
	"bcon" |
	"bg" |
	"fdcon" |
	"fdstep" |
	"fdres" |
	"id" |
	"pmcon0" |
	"pmcon1" |
	"osc_con" |
	"pll_con" |
	"cmcon" |
	"passwd" |
	"feal" |
	"feah" |
	"cocon" |
	"misc_con" |
	"xaddrh" |
	"ircon3" |
	"ircon4" |
	"modpisel1" |
	"modpisel2" |
	"pmcon2" |
	"modsusp" |
	"port_page" |
	"p0_data" |
	"p0_dir" |
	"p1_data" |
	"p1_dir" |
	"p2_data" |
	"p2_dir" |
	"p3_data" |
	"p3_dir" |
	"p4_data" |
	"p4_dir" |
	"p5_data" |
	"p5_dir" |
	"p0_pudsel" |
	"p0_puden" |
	"p1_pudsel" |
	"p1_puden" |
	"p2_pudsel" |
	"p2_puden" |
	"p3_pudsel" |
	"p3_puden" |
	"p4_pudsel" |
	"p4_puden" |
	"p5_pudsel" |
	"p5_puden" |
	"p0_altsel0" |
	"p0_altsel1" |
	"p1_altsel0" |
	"p1_altsel1" |
	"p3_altsel0" |
	"p3_altsel1" |
	"p4_altsel0" |
	"p4_altsel1" |
	"p5_altsel0" |
	"p5_altsel1" |
	"p0_od" |
	"p1_od" |
	"p3_od" |
	"p4_od" |
	"p5_od" |
	"adc_page" |
	"adc_globctr" |
	"adc_globstr" |
	"adc_prar" |
	"adc_lcbr" |
	"adc_inpcr0" |
	"adc_etrcr" |
	"adc_chctr0" |
	"adc_chctr1" |
	"adc_chctr2" |
	"adc_chctr3" |
	"adc_chctr4" |
	"adc_chctr5" |
	"adc_chctr6" |
	"adc_chctr7" |
	"adc_resr0l" |
	"adc_resr0h" |
	"adc_resr1l" |
	"adc_resr1h" |
	"adc_resr2l" |
	"adc_resr2h" |
	"adc_resr3l" |
	"adc_resr3h" |
	"adc_resra0l" |
	"adc_resra0h" |
	"adc_resra1l" |
	"adc_resra1h" |
	"adc_resra2l" |
	"adc_resra2h" |
	"adc_resra3l" |
	"adc_resra3h" |
	"adc_rcr0" |
	"adc_rcr1" |
	"adc_rcr2" |
	"adc_rcr3" |
	"adc_vfcr" |
	"adc_chinfr" |
	"adc_chincr" |
	"adc_chinsr" |
	"adc_chinpr" |
	"adc_evinfr" |
	"adc_evincr" |
	"adc_evinsr" |
	"adc_evinpr" |
	"adc_crcr1" |
	"adc_crpr1" |
	"adc_crmr1" |
	"adc_qmr0" |
	"adc_qsr0" |
	"adc_q0r0" |
	"adc_qbur0" |
	"adc_qinr0" |
	"t2_t2con" |
	"tf2" |
	"exf2" |
	"exen2" |
	"tr2" |
	"ct2" |
	"cprl2" |
	"t2_t2mod" |
	"t2_rc2l" |
	"t2_rc2h" |
	"t2_t2l" |
	"t2_t2h" |
	"ccu6_page" |
	"ccu6_cc63srl" |
	"ccu6_cc63srh" |
	"ccu6_tctr4l" |
	"ccu6_tctr4h" |
	"ccu6_mcmoutsl" |
	"ccu6_mcmoutsh" |
	"ccu6_isrl" |
	"ccu6_isrh" |
	"ccu6_cmpmodifl" |
	"ccu6_cmpmodifh" |
	"ccu6_cc60srl" |
	"ccu6_cc60srh" |
	"ccu6_cc61srl" |
	"ccu6_cc61srh" |
	"ccu6_cc62srl" |
	"ccu6_cc62srh" |
	"ccu6_cc63rl" |
	"ccu6_cc63rh" |
	"ccu6_t12prl" |
	"ccu6_t12prh" |
	"ccu6_t13prl" |
	"ccu6_t13prh" |
	"ccu6_t12dtcl" |
	"ccu6_t12dtch" |
	"ccu6_tctr0l" |
	"ccu6_tctr0h" |
	"ccu6_cc60rl" |
	"ccu6_cc60rh" |
	"ccu6_cc61rl" |
	"ccu6_cc61rh" |
	"ccu6_cc62rl" |
	"ccu6_cc62rh" |
	"ccu6_t12msell" |
	"ccu6_t12mselh" |
	"ccu6_ienl" |
	"ccu6_ienh" |
	"ccu6_inpl" |
	"ccu6_inph" |
	"ccu6_issl" |
	"ccu6_issh" |
	"ccu6_pslr" |
	"ccu6_mcmctr" |
	"ccu6_tctr2l" |
	"ccu6_tctr2h" |
	"ccu6_modctrl" |
	"ccu6_modctrh" |
	"ccu6_trpctrl" |
	"ccu6_trpctrh" |
	"ccu6_mcmoutl" |
	"ccu6_mcmouth" |
	"ccu6_isl" |
	"ccu6_ish" |
	"ccu6_pisel0l" |
	"ccu6_pisel0h" |
	"ccu6_pisel2" |
	"ccu6_t12l" |
	"ccu6_t12h" |
	"ccu6_t13l" |
	"ccu6_t13h" |
	"ccu6_cmpstatl" |
	"ccu6_cmpstath" |
	"ssc_pisel" |
	"ssc_conl" |
	"ssc_conh" |
	"ssc_tbl" |
	"ssc_rbl" |
	"ssc_brl" |
	"ssc_brh" |
	"adcon" |
	"v3" |
	"v2" |
	"v1" |
	"v0" |
	"auad1" |
	"auad0" |
	"can_bsy" |
	"rwen" |
	"adl" |
	"adh" |
	"data0" |
	"data1" |
	"data2" |
	"data3" |
	"mdustat" |
	"bsy" |
	"ierr" |
	"irdy" |
	"mducon" |
	"md0" |
	"mr0" |
	"md1" |
	"mr1" |
	"md2" |
	"mr2" |
	"md3" |
	"mr3" |
	"md4" |
	"mr4" |
	"md5" |
	"mr5" |
	"cd_cordxl" |
	"cd_cordxh" |
	"cd_cordyl" |
	"cd_cordyh" |
	"cd_cordzl" |
	"cd_cordzh" |
	"cd_statc" |
	"keepz" |
	"keepy" |
	"keepx" |
	"dmap" |
	"int_en" |
	"eoc" |
	"error" |
	"cd_bsy" |
	"cd_con" |
	"wdtcon" |
	"wdtrel" |
	"wdtwinb" |
	"wdtl" |
	"wdth" |
	"t21_t2con" |
	"t21_t2mod" |
	"t21_rc2l" |
	"t21_rc2h" |
	"t21_t2l" |
	"t21_t2h" |
	"scon1" |
	"sm01" |
	"sm11" |
	"sm21" |
	"ren1" |
	"tb81" |
	"rb81" |
	"ti1" |
	"ri1" |
	"sbuf1" |
	"bcon1" |
	"bg1" |
	"fdcon1" |
	"fdstep1" |
	"fdres1" |
	"mmcr2" |
	"mmcr" |
	"mmsr" |
	"mmbpcr" |
	"mmicr" |
	"mmdr" |
	"hwbpsr" |
	"hwbpdr" |
	"mmwr1" |
	"mmwr2" |
	"a" |
	"c" |
	"r0" |
	"r1" |
	"r2" |
	"r3" |
	"r4" |
	"r5" |
	"r6" |
	"r7" |
	"p0" |
	"sp" |
	"p1" |
	"p2" |
	"ie" |
	"p3" |
	"et" |
	"rxd" |
	"txd" |
	"int0" |
	"int1" |
	"t0" |
	"t1" |
	"wr" |
	"rd" |
	"dptr" { addToken(Token.VARIABLE); }

	/* 8051 Instructions. */
    "ACALL" |
	"ADD" |
	"ADDC" |
	"AJMP" |
	"ANL" |
	"CJNE" |
	"CLR" |
	"CPL" |
	"DA" |
	"DEC" |
	"DIV" |
	"DJNZ" |
	"INC" |
	"JB" |
	"JBC" |
	"JC" |
	"JMP" |
	"JNB" |
	"JNC" |
	"JNZ" |
	"JZ" |
	"LCALL" |
	"LJMP" |
	"MOV" |
	"MOVC" |
	"MOVX" |
	"MUL" |
	"NOP" |
	"ORL" |
	"POP" |
	"PUSH" |
	"RET" |
	"RETI" |
	"RL" |
	"RLC" |
	"RR" |
	"RRC" |
	"SETB" |
	"SJMP" |
	"SUBB" |
	"SWAP" |
	"XCH" |
	"XCHD" |
	"XRL"       { addToken(Token.RESERVED_WORD); }

}

<YYINITIAL> {

	{LineTerminator}				{ addNullToken(); return firstToken; }

	{WhiteSpace}+					{ addToken(Token.WHITESPACE); }

	/* String/Character Literals. */
	{CharLiteral}					{ addToken(Token.LITERAL_CHAR); }
	{UnclosedCharLiteral}			{ addToken(Token.ERROR_CHAR); /*addNullToken(); return firstToken;*/ }
	{StringLiteral}				{ addToken(Token.LITERAL_STRING_DOUBLE_QUOTE); }
	{UnclosedStringLiteral}			{ addToken(Token.ERROR_STRING_DOUBLE); addNullToken(); return firstToken; }

	/* Labels. */
	{Label}						{ addToken(Token.PREPROCESSOR); }

	^%({Letter}|{Digit})*			{ addToken(Token.FUNCTION); }

	/* Comment Literals. */
	{CommentBegin}.*				{ addToken(Token.COMMENT_EOL); addNullToken(); return firstToken; }

	/* Operators. */
	{Operator}					{ addToken(Token.OPERATOR); }

	/* Numbers */
	{Number}						{ addToken(Token.LITERAL_NUMBER_DECIMAL_INT); }

	/* Ended with a line not in a string or comment. */
	<<EOF>>						{ addNullToken(); return firstToken; }

	/* Catch any other (unhandled) characters. */
	{Identifier}					{ addToken(Token.IDENTIFIER); }
	.							{ addToken(Token.IDENTIFIER); }

}
