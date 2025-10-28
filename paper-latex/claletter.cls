%%
%% This is file `sriletter.cls',
\NeedsTeXFormat{LaTeX2e}[1995/06/01]
\ProvidesClass{sriletter}[1996/10/23]
\RequirePackage{epsfig}
\LoadClass{letter}
\def\ps@firstpage{\newdimen\top@raise\newdimen\bot@raise%
%%\def\@oddhead{\top@raise=-27pt\advance\top@raise by\topmargin %
\def\@oddhead{\top@raise=0pt\advance\top@raise by\topmargin %
%%\def\srilogo{\epsfig{file=minerva.eps,height=24mm}}
%%\def\srilogo{\epsfig{file=intestazione.epsf.eps,height=24mm}}
\def\srilogo{\parbox{1,5cm}{\epsfig{file=figures/minerva-new.eps,height=20mm}}
\parbox{12cm}{\begin{center}
~\\~\\
{\Large UNIVERSIT\`A DEGLI STUDI DI MILANO}\\
{\large Dipartimento di Informatica}\\
% {\em Polo Didattico e di Ricerca di Crema}\\
{\small 18 Via Celoria - 201333 MILAN -- ITALY}\\
{\Large~}\\
{\Large~}\\
\end{center}}}
\raisebox{\top@raise}[0pt][0pt]{\srilogo}\hfill}%
%%\def\@oddfoot{\bot@raise=-614pt % Topmargin 25pt, Headheight 12pt,Headsep 45pt,Textheight 505pt,footskip 25pt
\def\@oddfoot{\bot@raise=-650pt % Topmargin 25pt, Headheight 12pt,Headsep 45pt,Textheight 505pt,footskip 25pt
\advance\bot@raise by \topmargin\advance\bot@raise by \headheight\advance\bot@raise by \headsep\advance\bot@raise by \textheight\advance\bot@raise by \footskip%
\advance\bot@raise by -0.75in%
\font\sri@SRI=cmssbx10 scaled\magstep3%
\hbox to 0pt{\raisebox{\bot@raise}[0pt]{\hspace*{8pt}\hspace*{-\oddsidemargin} % Subtract off oddsidemargin in case user changed it
%\vbox{\hbox to \textwidth{\sri@SRI Universit\`a di Milano\hfill}}\\%
%\vspace{-0.125in}%
\hbox to 6.75in{{\@setsize\tiny{9pt}\viiipt\@viiipt\sf%Get us to 8pt for the following
\ifx\fromname\@empty \fromsig{} \else \fromname{} \fi  $\bullet$ %
%%\ifx\fromlocation\@empty\else \fromlocation{} $\bullet$ \fi%
%%65 Via Bramante $\bullet$ 26013 - Crema (Italy) $\bullet$ %
marco.anisetti@unimi.it $\bullet$
\ifx\telephonenum\@empty \else \telephonenum{} \fi $\bullet$ %
% SRI's main FAX:  326-5512, division's 859-6171, AIC's 859-3735
%ho tolto il fax
%Fax: %
%\ifx\faxphonenum\@empty  \else \faxphonenum{} \fi %
%$\bullet$
sesar.di.unimi.it
\hfill}}}}\hss}
%\raisebox%
% {-45pt}[0pt]{\hbox to \textwidth
% {\hspace*{100pt}\xpt\fromlocation \hfill
%\telephonenum}}
%%%\hss}\def\@evenhead{}\def\@evenfoot{}
}
% SRI

%%%\def\ps@plain{%
%%%      \let\@oddhead\@empty
%%%      \def\@oddfoot{\normalfont\hfil\thepage\hfil}%
%%%      \def\@evenfoot{\normalfont\hfil\thepage\hfil}}

\def\ps@plain{
      \let\@oddhead{\parbox{1cm}{\epsfig{file=minerva.eps,height=10mm}}\parbox{20cm}{{\sc
UNIVERSIT\`A DI MILANO --- Dipartimento di Tecnologie
dell'Informazione}}}
      \let\@evenhead{\parbox{1cm}{\epsfig{file=minerva.eps,height=10mm}}\parbox{20cm}{{\sc
UNIVERSIT\`A DI MILANO --- Dipartimento di Tecnologie
dell'Informazione}}}      \def\@oddfoot{\normalfont\hfil\thepage\hfil}%
      \def\@evenfoot{\normalfont\hfil\thepage\hfil}}


\newcommand*{\faxnumber}[1]{\def\faxphonenum{#1}}
%\name{Prof. Claudio Ardagna} not used. defined in the letter
\signature{}
\address{}
\location{}
% my numbers
\telephone{+39-0373-898051}
\faxnumber{+39-0373-898010}
\endinput
%%
%% End of file `sriletter.cls'.
