###############################################################################
#
#   Class: NaturalDocs::Languages::Matlab
#
###############################################################################
#
#   A subclass to handle the language variations of the Matlab language.
#
#
#   Topic: Language Support
#
#       Supported:
#
#       - Classes
#       - Functions
#       - Properties
#
#
###############################################################################

use strict;
use integer;
use NaturalDocs::Settings;

package NaturalDocs::Languages::Matlab;

use base 'NaturalDocs::Languages::Advanced';

###############################################################################
# Group: Constants

#
#	array: matlabKeywords
#
#	An array containing all Matlab keywords, used while coloring code
#

my @matlabKeywords =  (	'break', 
						'case', 
						'catch', 
						'classdef', 
						'continue', 
						'else', 
						'elseif', 
						'end', 
						'for', 
						'function', 
						'global', 
						'if', 
						'otherwise', 
						'parfor', 
						'persistent', 
						'return', 
						'spmd', 
						'switch', 
						'try', 
						'while' );

###############################################################################
# Group: Variables

#
#	hash: modifiers
#
#	An hash containing modifiers for current topic. Matlab decleration for modifiers is
#	at the beginning of the block declaration, so they stay the same for the whole block.
#	For access, public => 1, protected => 2, private => 3.
#
my %modifiers = ( 	'access' => '1',
					'sealed' => '0',
					'static' => '0',
					'abstract' => '0' );
					
###############################################################################  
# Group: Interface Functions

#
#   Function: PackageSeparator
#   Returns the package separator symbol.
#
sub PackageSeparator
    {  return '.';  };

#
#   Function: EnumValues
#   Returns the <EnumValuesType> that describes how the language handles enums.
#
sub EnumValues
    {  return ::ENUM_GLOBAL();  };
	

#
#   Function: ParseFile
#
#   Parses the passed source file, sending comments acceptable for documentation to <NaturalDocs::Parser->OnComment()>.
#
#   Parameters:
#
#       sourceFile - The <FileName> to parse.
#       topicList - A reference to the list of <NaturalDocs::Parser::ParsedTopics> being built by the file.
#
#   Returns:
#
#       The array ( autoTopics, scopeRecord ).
#
#       autoTopics - An arrayref of automatically generated topics from the file, or undef if none.
#       scopeRecord - An arrayref of <NaturalDocs::Languages::Advanced::ScopeChanges>, or undef if none.
#
sub ParseFile #(sourceFile, topicsList)
{
	my ($self, $sourceFile, $topicsList) = @_;
	
	my @tokensAndComments = $self->ParseForCommentsAndTokens($sourceFile, ['%'], ['%{', '%}'], ['%%']);
	my $tokens = $self->Tokens();
	my $index = 0;
	my $lineNumber = 1;
	
	while ($index < scalar @$tokens)
    {
        if ($self->TryToSkipWhitespace(\$index, \$lineNumber) ||
            $self->TryToGetClass(\$index, \$lineNumber, $sourceFile) ||
			$self->TryToGetProperties(\$index, \$lineNumber) ||
			$self->TryToGetMethod(\$index, \$lineNumber, @tokensAndComments)
			)
            {
            # The functions above will handle everything.
            }
        elsif (lc($tokens->[$index]) eq 'end')
            {
            if (lc($self->ClosingScopeSymbol()) eq 'end')
                {  $self->EndScope($lineNumber);  };

            $index++;
            }

        else
            {
            $self->SkipRestOfStatement(\$index, \$lineNumber);
            };
        };

    # Don't need to keep these around.		
    $self->ClearTokens();

    my $autoTopics = $self->AutoTopics();

    my $scopeRecord = $self->ScopeRecord();
    if (defined $scopeRecord && !scalar @$scopeRecord)
        {  $scopeRecord = undef;  };

    return ( $autoTopics, $scopeRecord );
    };

################################################################################
# Group: Statement Parsing Functions
# All functions here assume that the current position is at the beginning of a statement.
#
#
#   Function: TryToGetClass
#
#   Determines whether the position is at a class declaration statement, and if so, generates a topic for it, skips it, and
#   returns true.
#
#   Supported Syntaxes:
#
#       - Classes
#
#	Parameter:
#
#       indexRef - A reference to the current index.
#       lineNumberRef - A reference to the current line number.
#		sourceFile - The complete path to the source file.
#

sub TryToGetClass #(indexRef, lineNumberRef, sourceFile)
{
    my ($self, $indexRef, $lineNumberRef, $sourceFile) = @_;
    my $tokens = $self->Tokens();

    my $index = $$indexRef;
    my $lineNumber = $$lineNumberRef;

	# Check if class
	if ($tokens->[$index] eq 'classdef')
	{
        $index++;
	}
    else
    {  return undef;  };
	
	# Ignoring all Class Attributes
	$self->TryToSkipAttribute(\$index, \$lineNumber); 
	
    $self->TryToSkipWhitespace(\$index, \$lineNumber);
	
	my $name;

	# Getting class name
    while ($tokens->[$index] =~ /^[a-z_\@]/i)
    {
        $name .= $tokens->[$index];
        $index++;
    };

    if (!defined $name)
        {  return undef;  };
		
    $self->TryToSkipWhitespace(\$index, \$lineNumber);
	
    my @parents;
	
	# Check inheritance
	if ($tokens->[$index] eq '<')
	{
		do
		{
			$index++;

            $self->TryToSkipWhitespace(\$index, \$lineNumber);

            my $parentName;

            while ($tokens->[$index] =~ /^[a-z_\.\@]/i)
            {
                $parentName .= $tokens->[$index];
                $index++;
            }
            if (!defined $parentName)
                {  return undef;  };
            push @parents, ($parentName);

            $self->TryToSkipWhitespace(\$index, \$lineNumber);
		}
		while($tokens->[$index] eq '&')
	}
	
    my @scopeIdentifiers = $self->TryToGetIdentifiers($sourceFile);
    $name = join('.', @scopeIdentifiers, $name);
	
    my $autoTopic = NaturalDocs::Parser::ParsedTopic->New(::TOPIC_CLASS(), $name,
														 undef, $self->CurrentUsing(),
														 undef,
														 undef, undef, $$lineNumberRef, undef, undef, undef, \@parents);

    $self->AddAutoTopic($autoTopic);
	
    NaturalDocs::Parser->OnClass($autoTopic->Package());

    foreach my $parent (@parents)
    {
        NaturalDocs::Parser->OnClassParent($autoTopic->Package(), NaturalDocs::SymbolString->FromText($parent), 
																$self->CurrentScope(), $self->CurrentUsing(), 
																::RESOLVE_RELATIVE());
    };

    $self->StartScope('end', $lineNumber, $autoTopic->Package());
	
    $$indexRef = $index;
    $$lineNumberRef = $lineNumber;

    return 1;
};
	
	
#
#   Function: TryToGetFunction
#
#   Determines if the position is on a function declaration statement, 
#   and if so, generates a topic for each function, skips them, and returns true.
#
#   Supported Syntaxes:
#
#       - Functions
#
#	Parameter:
#
#       indexRef - A reference to the current index.
#       lineNumberRef - A reference to the current line number.
#		tokensAndComment - An array containing all code (tokenized) and comments.
#
sub TryToGetFunction #(indexRef, lineNumberRef, tokensAndComments)
{
    my ($self, $indexRef, $lineNumberRef, @tokensAndComments) = @_;
		
    my $tokens = $self->Tokens();

    my $index = $$indexRef;
    my $lineNumber = $$lineNumberRef;
	
	if(lc($tokens->[$index]) ne 'function')
	{	return undef;	}
	else
	{
		my $name;
		my $startIndex = $index;
		my $startLine = $lineNumber;
		$self->GenericSkip(\$index, \$lineNumber);	
        $self->TryToSkipWhitespace(\$index, \$lineNumber);
		
		# We either got return variable or function name.
		# We consider it being the return value, and if we don't find "=" after, we'll consider it the name
		
		my $returnValue = $tokens->[$index];
		$self->GenericSkip(\$index, \$lineNumber);	

        $self->TryToSkipWhitespace(\$index, \$lineNumber);
		
		# If assumption is wrong
		if($tokens->[$index] ne '=')
		{
			$name = $returnValue;
			$returnValue = undef;
		}
		else
		{
			$self->GenericSkip(\$index, \$lineNumber);	
			$self->TryToSkipWhitespace(\$index, \$lineNumber);
			$name = $tokens->[$index];
			$self->GenericSkip(\$index, \$lineNumber);
			$self->TryToSkipWhitespace(\$index, \$lineNumber);
		}
		# We skip attriutes
		$self->TryToSkipAttribute(\$index, \$lineNumber);		
		
		# We're at the end of the declaration line
        my $prototype = $self->NormalizePrototype( $self->CreateString($startIndex, $index) );
		
		$self->GenericSkipUntilAfter(\$index, \$lineNumber, "end");	
		
		my $code;
		
		# If "-code" command line option
		if (NaturalDocs::Settings->ShowCode())
		{
			$code = $self->CreateAndColorCode($startIndex, $index, @tokensAndComments);
		}
		my $topic = NaturalDocs::Parser::ParsedTopic->New(::TOPIC_FUNCTION(), $name,
																  $self->CurrentScope(), $self->CurrentUsing(),
																  $prototype,
																  undef, undef, $startLine, undef, \%modifiers, $code);
		$self->AddAutoTopic($topic);
		
		$$indexRef = $index;
		$$lineNumberRef = $lineNumber;
		return 1;
	}
}

#
#   Function: TryToGetAbstractFunction
#
#	Try to get all abstract functions within a "method" declaration that contained "abstract". 
#	The definition of "abstract" must be known before calling this function.
#
#	Parameter:
#
#       indexRef - A reference to the current index.
#       lineNumberRef - A reference to the current line number.
#		tokensAndComment - An array containing all code (tokenized) and comments.
#

sub TryToGetAbstractFunction #($indexRef, $lineNumberRef)
{
	my ($self, $indexRef, $lineNumberRef) = @_;
    my $tokens = $self->Tokens();

    my $index = $$indexRef;
    my $lineNumber = $$lineNumberRef;
	
	my $name;
	my $startIndex = $index;
	my $startLine = $lineNumber;
	
	$self->TryToSkipWhitespace(\$index, \$lineNumber);
	
	# We either got return variable or function name.
	# We consider it being the return value, and if we don't find "=" after, we'll consider it the name
	
	my $returnValue = $tokens->[$index];
	
	$self->GenericSkip(\$index, \$lineNumber);	
	$self->TryToSkipWhitespace(\$index, \$lineNumber);
	
	# If assumption is wrong
	if($tokens->[$index] ne '=')
	{
		$name = $returnValue;
		$returnValue = undef;
	}
	else
	{
		$self->GenericSkip(\$index, \$lineNumber);	
		$self->TryToSkipWhitespace(\$index, \$lineNumber);
		$name = $tokens->[$index];
		$self->GenericSkip(\$index, \$lineNumber);
		$self->TryToSkipWhitespace(\$index, \$lineNumber);
	}
	# We skip attriutes
	if (!$self->TryToSkipAttribute(\$index, \$lineNumber) )
	{
	#	return undef;
	}
	
	# We may have semicolon at the end of the statement
	if ($tokens->[$index] eq ';')
	{	
		$self->GenericSkip(\$index, \$lineNumber);	
	}
	
	# We're at the end of the declaration line
	my $prototype = $self->NormalizePrototype( $self->CreateString($startIndex, $index) );
	my $topic = NaturalDocs::Parser::ParsedTopic->New(::TOPIC_FUNCTION(), $name,
															  $self->CurrentScope(), $self->CurrentUsing(),
															  $prototype,
															  undef, undef, $startLine, undef, \%modifiers);
	$self->AddAutoTopic($topic);
	$$indexRef = $index;
	$$lineNumberRef = $lineNumber;
	return 1;
}


#
#   Function: TryToGetProperties
#
#   Determines if the position is on a property declaration statement, and if so, generates a topic for each variable, skips the
#   statement, and returns true.
#
#	Parameter:
#
#       indexRef - A reference to the current index.
#       lineNumberRef - A reference to the current line number.
#

sub TryToGetProperties #(indexRef, lineNumberRef)
{
    my ($self, $indexRef, $lineNumberRef) = @_;
    my $tokens = $self->Tokens();

    my $index = $$indexRef;
    my $lineNumber = $$lineNumberRef;
	
	# If this is properties
	if(lc($tokens->[$index]) ne 'properties')
	{	return undef;	}
	else
	{
		$index++;
		
		# Retreving properties modifiers
		$self->TryToGetModifiers(\$index, \$lineNumber);
		
		my $accessName;
		if ($modifiers{'access'} == 1)
		{$accessName = 'public ';}
		elsif($modifiers{'access'} == 2)
		{$accessName = 'protected ';}
		elsif($modifiers{'access'} == 3)
		{$accessName = 'private ';}
		
		$self->TryToSkipWhitespace(\$index, \$lineNumber);
		
		# We read EVERY properties
		while(lc($tokens->[$index]) ne 'end')
		{
			my $name;
			$self->TryToSkipWhitespace(\$index, \$lineNumber);
			
			while ($tokens->[$index] =~ /^[a-z\@\_]/i)
			{
				$name .= $tokens->[$index];
				$index++;
			};
			
			my $startLine = $lineNumber;

			$self->TryToSkipWhitespace(\$index, \$lineNumber);
			
			if ($tokens->[$index] eq '=')
			{
				do
				{
					$self->GenericSkip(\$index, \$lineNumber);
				}
				while ($tokens->[$index] ne "\n" && $tokens->[$index] ne ";");
			};
			
			if ($tokens->[$index] eq ';')
				{	$index++;	};
				
			my $prototype = $self->NormalizePrototype( $accessName . ' ' . $name );
			
			my $topic = NaturalDocs::Parser::ParsedTopic->New(::TOPIC_PROPERTY(), $name,
															  $self->CurrentScope(), $self->CurrentUsing(),
															  $prototype,
															  undef, undef, $startLine, undef, \%modifiers, undef);
			$self->AddAutoTopic($topic);
			my $scope = $self->CurrentScope();
			
			$self->TryToSkipWhitespace(\$index, \$lineNumber);
			# At this point, $index is either on the next property or end.
		}
		
		$index++;

		$$indexRef = $index;
		$$lineNumberRef = $lineNumber;
	
		return 1;
	};	
}

#
#	Function: TryToGetMethod
#   Determines if the position is on a method declaration statement, and if so, gets attributes, 
#	skips the statement, and returns true.
#
#	Parameter:
#
#       indexRef - A reference to the current index.
#       lineNumberRef - A reference to the current line number.
#		tokensAndComments - An array containing all code (tokenized) and comments.
#

sub TryToGetMethod #(indexRef, lineNumberRef, tokensAndComments)
{
    my ($self, $indexRef, $lineNumberRef, @tokensAndComments) = @_;
    my $tokens = $self->Tokens();

    my $index = $$indexRef;
    my $lineNumber = $$lineNumberRef;
	
	if(lc($tokens->[$index]) ne 'methods')
	{	return undef;	}
	else
	{
		$index++;
		$self->TryToGetModifiers(\$index, \$lineNumber);
		
		# There could be a semicolon after the "methods"
		$self->GenericSkip(\$index, \$lineNumber);
		
        $self->StartScope('end', $lineNumber, undef, undef, undef);
		
		while(lc($tokens->[$index]) ne 'end' && $index < scalar @$tokens)
		{
			if ($self->TryToSkipWhitespace(\$index, \$lineNumber) ||
				$self->TryToGetFunction(\$index, \$lineNumber, @tokensAndComments) ||
				$self->TryToGetAbstractFunction(\$index, \$lineNumber))
				{
				# The functions above will handle everything.
				}
			else
				{
				$self->SkipRestOfStatement(\$index, \$lineNumber);
				};
		}
		
		$$indexRef = $index;
		$$lineNumberRef = $lineNumber;
		return 1;
	}
}

#
#	Function: TryToGetModifiers
#	If the current position is on an opening of attributes declarations, we will extract them and return them. Index is returned
#	after the closing symbol of the declaration (i.e., ")").
#
#	Parameter:
#
#       indexRef - A reference to the current index.
#       lineNumberRef - A reference to the current line number.
#

sub TryToGetModifiers #(indexRef, lineNumberRef)
{
	my ($self, $indexRef, $lineNumberRef) = @_;
    my $tokens = $self->Tokens();
	my $index = $$indexRef;
    my $lineNumber = $$lineNumberRef;
	
	$self->TryToSkipWhitespace(\$index, \$lineNumber);
	
	%modifiers = ( 	'access' => '1',
					'sealed' => '0',
					'static' => '0',
					'abstract' => '0',
					'const' => '0' );

	if ($tokens->[$index] eq '(')
	{
		$index++;
		while ($tokens->[$index] ne ')')
		{
			if (lc($tokens->[$index]) eq 'access')
			{
				$index++;
				$self->TryToSkipWhitespace(\$index, \$lineNumber);
				$self->GenericSkip(\$index, \$lineNumber);
				$self->TryToSkipWhitespace(\$index, \$lineNumber);
				
				if (lc($tokens->[$index]) eq 'public')
				{	$modifiers{'access'} = '1';	}
				
				if (lc($tokens->[$index]) eq 'protected')
				{	$modifiers{'access'} = '2';	}
				
				if (lc($tokens->[$index]) eq 'private')
				{	$modifiers{'access'} = '3';	}
			}
			elsif (lc($tokens->[$index]) eq 'static')
			{
				$modifiers{'static'} = '1';
			}
			elsif (lc($tokens->[$index]) eq 'abstract')
			{
				$modifiers{'abstract'} = '1';
			}
			elsif (lc($tokens->[$index]) eq 'sealed')
			{
				$modifiers{'sealed'} = '1';
			}
			elsif (lc($tokens->[$index]) eq 'constant')
			{
				$modifiers{'const'} = '1';
			}
			$self->GenericSkip(\$index, \$lineNumber);
		}
		
		$index++;
		
		$$indexRef = $index;
		$$lineNumberRef = $lineNumber ;
	}
}

################################################################################
# Group: Low Level Parsing Functions
#
#	Function: TryToSkipAttribute
#	If the current position is on an opening of attributes declarations, skip them and return true. Index is returned 
#	after the closing symbol of the attreibute declaration.
#
#   Parameters:
#
#       indexRef - A reference to the current index.
#       lineNumberRef - A reference to the current line number.
#

sub TryToSkipAttribute #(indexRef, lineNumberRef)
{
	my ($self, $indexRef, $lineNumberRef) = @_;
    my $tokens = $self->Tokens();

    my $success;
	
	$self->TryToSkipWhitespace($indexRef, $lineNumberRef);

	if ($tokens->[$$indexRef] eq '(')
	{
			$success = 1;
			$$indexRef++;
			$self->GenericSkipUntilAfter($indexRef, $lineNumberRef, ')');
			$self->TryToSkipWhitespace($indexRef, $lineNumberRef);
	};
    return $success;
};

#
#   Function: GenericSkip
#
#   Advances the position one place through general code.
#
#   - If the position is on a string, it will skip it completely.
#   - If the position is on an if, for, while, switch, try, it will skip until the past the closing symbol.
#   - If the position is on whitespace (including comments and preprocessing directives), it will skip it completely.
#   - Otherwise it skips one token.
#
#   Parameters:
#
#       indexRef - A reference to the current index.
#       lineNumberRef - A reference to the current line number.
#
sub GenericSkip #(indexRef, lineNumberRef)
    {
    my ($self, $indexRef, $lineNumberRef) = @_;
    my $tokens = $self->Tokens();
		my $name = $tokens->[$$indexRef];

     if (lc($tokens->[$$indexRef]) eq "try" ||
		 lc($tokens->[$$indexRef]) eq "switch" ||
		 lc($tokens->[$$indexRef]) eq "for" ||
		 lc($tokens->[$$indexRef]) eq "while" ||
		 lc($tokens->[$$indexRef]) eq "if")
        {
        $$indexRef++;
        $self->GenericSkipUntilAfter($indexRef, $lineNumberRef, "end");
        }
	elsif ($tokens->[$$indexRef] eq '(')
        {
        $$indexRef++;
        $self->GenericSkipUntilAfter($indexRef, $lineNumberRef, ')');
        }
    elsif ($tokens->[$$indexRef] eq '[')
        {
        $$indexRef++;
        $self->GenericSkipUntilAfter($indexRef, $lineNumberRef, ']');
		my $name = $tokens->[$$indexRef];
        }
    elsif ($self->TryToSkipWhitespace($indexRef, $lineNumberRef) ||
            $self->TryToSkipString($indexRef, $lineNumberRef))
        {
        }
    else
        {  $$indexRef++;  };
    };


#
#   Function: GenericSkipUntilAfter
#
#   Advances the position via <GenericSkip()> until a specific token is reached and passed.
#
sub GenericSkipUntilAfter #(indexRef, lineNumberRef, token)
    {
    my ($self, $indexRef, $lineNumberRef, $token) = @_;
    my $tokens = $self->Tokens();
	
    while ($$indexRef < scalar @$tokens && lc($tokens->[$$indexRef]) ne $token)
	{  
		$self->GenericSkip($indexRef, $lineNumberRef); 
		# If wanted token is "end", current token is "end", we check that it actually is an acceptable "end".
		# If it is, we ain't got any problem, if it ain't, we have to do a GenericSkip
		if ($token eq "end" && !$self->IsAcceptableEnd($indexRef))
		{
			$self->GenericSkip($indexRef, $lineNumberRef); 			
		}
	};

    if ($tokens->[$$indexRef] eq "\n")
        {  $$lineNumberRef++;  };
    $$indexRef++;
    };


#
#   Function: TryToSkipString
#   If the current position is on a string delimiter, skip past the string and return true.
#
#   Parameters:
#
#       indexRef - A reference to the index of the position to start at.
#       lineNumberRef - A reference to the line number of the position.
#
#   Returns:
#
#       Whether the position was at a string.
#
#   Syntax Support:
#
#       - Supports quotes, apostrophes, and at-quotes.
#
sub TryToSkipString #(indexRef, lineNumberRef)
{
    my ($self, $indexRef, $lineNumberRef) = @_;
	my $tokens = $self->Tokens();
	
	# You don't love Matlab enough: Apostrophe can be used for transpose instead of string delimiter.
	# Obviously, we don't want to confuse both.
	if($tokens->[$$indexRef] eq "\'" && $tokens->[$$indexRef-1] !~ /[a-z0-9_\}\)\]]$/i)
	{
		return ($self->SUPER::TryToSkipString($indexRef, $lineNumberRef, '\'') ||
				   $self->SUPER::TryToSkipString($indexRef, $lineNumberRef, '"') );
	}
	else
	{return undef;}
};
#
#   Function: TryToSkipWhitespace
#   If the current position is on a whitespace token, a line break token, or a comment, it skips them and returns true.  If there are
#   a number of these in a row, it skips them all.
#
sub TryToSkipWhitespace #(indexRef, lineNumberRef)
{
    my ($self, $indexRef, $lineNumberRef) = @_;
    my $tokens = $self->Tokens();

    my $result;

    while ($$indexRef < scalar @$tokens)
    {
        if ($tokens->[$$indexRef] =~ /^[ \t]/)
        {
            $$indexRef++;
            $result = 1;
        }
        elsif ($tokens->[$$indexRef] eq "\n")
        {
            $$indexRef++;
            $$lineNumberRef++;
            $result = 1;
        }
        elsif ($self->TryToSkipComment($indexRef, $lineNumberRef))
        {
            $result = 1;
        }
        else
        {  last;  };
    };

    return $result;
};

#
#   Function: SkipRestOfStatement
#
#   Advances the position via <GenericSkip()> until after the end of the current statement, which is defined as a semicolon.
#
sub SkipRestOfStatement #(indexRef, lineNumberRef)
    {
    my ($self, $indexRef, $lineNumberRef) = @_;
    my $tokens = $self->Tokens();

    while ($$indexRef < scalar @$tokens &&
             $tokens->[$$indexRef] ne ';')
        {
        $self->GenericSkip($indexRef, $lineNumberRef);
        };
	$$indexRef++;
    };
	
#
#   Function: TryToSkipComment
#   If the current position is on a comment, skip past it and return true.
#
sub TryToSkipComment #(indexRef, lineNumberRef)
    {
    my ($self, $indexRef, $lineNumberRef) = @_;

    return ( $self->TryToSkipLineComment($indexRef, $lineNumberRef) ||
                $self->TryToSkipMultilineComment($indexRef, $lineNumberRef) );
    };
	
#
#   Function: TryToSkipLineComment
#   If the current position is on a line comment symbol, skip past it and return true.
#
sub TryToSkipLineComment #(indexRef, lineNumberRef)
    {
    my ($self, $indexRef, $lineNumberRef) = @_;
    my $tokens = $self->Tokens();

    if ($tokens->[$$indexRef] eq '%')
        {
        $self->SkipRestOfLine($indexRef, $lineNumberRef);
        return 1;
        }
    else
        {  return undef;  };
    };


#
#   Function: TryToSkipMultilineComment
#   If the current position is on an opening comment symbol, skip past it and return true.
#
sub TryToSkipMultilineComment #(indexRef, lineNumberRef)
    {
    my ($self, $indexRef, $lineNumberRef) = @_;
    my $tokens = $self->Tokens();

    if ($tokens->[$$indexRef] eq '%' && $tokens->[$$indexRef+1] eq '{')
        {
        $self->SkipUntilAfter($indexRef, $lineNumberRef, '%', '}');
        return 1;
        }
    else
        {  return undef;  };
    };
	
	
################################################################################
# Group: Tools
	
#
#	Function: IsAcceptableEnd
# 	In the code, if the current token is "end", check if it is an "acceptable" end, i.e. it ends a previous declaration, such
#	as "if", "for", etc...
#	If not, returns undef. Else, return 1.
#
	
sub IsAcceptableEnd #($indexRef)
{
	my ($self, $indexRef) = @_;
    my $tokens = $self->Tokens();
	my $index = $$indexRef;
	
	# Check that current token is "end"
	if(lc($tokens->[$index]) eq "end")
	{
		$index++;
		# Next token has to be either \s or \n. Anything else means it's not an acceptable "end".
		while(lc($tokens->[$index]) !~ /\n/ && lc($tokens->[$index]) =~ /\s/)
		{	$index++;	}
		
		# If we found \n without any other token (except \s) it's an acceptable "end".
		if(lc($tokens->[$index]) =~ /\n/)
		{	return 1;	}
		# Else it ain't
		else
		{	return undef;	}
	}
	else
	{	return 1;	}
}	
	
#
#	Function: TryToGetIdentifiers
#	Try to get identifiers of the sourcefile. In Matlab language, it means all subfolders beginning with a "+".
#

sub TryToGetIdentifiers #(sourceFile)
{
	my ($self, $sourceFile) = @_;
	
	my @pathClassIdentifiers = split(/\\/,$sourceFile);
	
	my @classIdentifiers;
	
	pop(@pathClassIdentifiers);
	my $identifier = pop(@pathClassIdentifiers);
	# While identifier begins with "+"
	while ($identifier =~ /^\+/)
	{
		$identifier =~ s/\+//;
		unshift @classIdentifiers, $identifier;
		$identifier = pop(@pathClassIdentifiers);
	}
	return (@classIdentifiers);
}

#
#   Function: CreateAndColorCode
#
#   Converts the specified tokens representing code into a string containing HTML coloration for keywords
#
#   Parameters:
#
#       startIndex - The starting index to convert.
#       endIndex - The ending index, which is *not inclusive*.
#		tokensAndComments - Array containing tokenized code and its comments
#
#   Returns:
#
#       The string.
#

sub CreateAndColorCode #(startIndex, endIndex, tokensAndComments)
{
    my ($self, $startIndex, $endIndex, @tokensAndComments) = @_;
    my $tokens = $self->Tokens();

    my $string;
	my $inString = 0;
	my $isCommentInCode = 0;
	# my $isBlockCommentInCode = 0;
	my $isBlockComment = 0;

    while ($startIndex < $endIndex && $startIndex < scalar @$tokens)
    {
		my $token = $tokensAndComments[$startIndex];
		my $coloredToken;
		my $isKeyword = 0;
		
		foreach my $keyword (@matlabKeywords)
		{
			if (lc($token) eq  $keyword)
			{
				$isKeyword = 1;
			}
		}
		
		if ($inString == 1)
		{
			$coloredToken = $token;
			if ($token eq '\'')
			{
			$inString = 0;
			$coloredToken .= '</FONT>';
			}
		}
		# If we're in a comment that's inside code
		elsif ($isCommentInCode)
		{
			$coloredToken = $token;
			# It ends at the end of the line
			if ($token eq "\n")
			{
				$isCommentInCode = 0;
				$coloredToken .= '</FONT>';
			}
		}
		elsif ($isKeyword)
		{
			$coloredToken = '<FONT COLOR="0000FF">' . $token . '</FONT>';
		}
		# elsif ($isBlockCommentInCode)
		# {
			# $coloredToken = $token;
			# It ends at the end of the block comment
			# if ($token eq '%' && $tokensAndComments[$startIndex+1] eq '}')
			# {
				# $isBlockCommentInCode = 0;
				# $coloredToken .= $tokensAndComments[++$startIndex] . '</FONT>';
			# }
		# }
		elsif ($isBlockComment && $token =~ /%}/)
		{
			$isBlockComment = 0;
			$coloredToken .= $token . '</FONT>';
		}
		elsif ($isBlockComment)
		{
			$coloredToken = $token;
		}
		elsif ($token eq '\'' && $tokensAndComments[$startIndex-1] !~ /[a-z0-9_\}\)\]]$/i)
		{
			$inString = 1;
			$coloredToken = '<FONT COLOR="C016FE">' . $token;
		}
		# If we have a block comment inside the code
		# elsif ($token eq '%' && $tokensAndComments[$startIndex+1] eq '{')
		# {
			# $isBlockCommentInCode = 1;
			# $coloredToken = '<FONT COLOR="347C2C">' . $token;
		# }
		# If we have comment inside a line of code
		elsif ($token eq '%')
		{
			$isCommentInCode = 1;
			$coloredToken = '<FONT COLOR="347C2C">' . $token;
		}
		elsif ($token =~ /^ *%{/)
		{
			$coloredToken = '<FONT COLOR="347C2C">' . $token;
			$isBlockComment = 1;
		}
		# If we have a comment line
		elsif ($token =~ /^ *%/)
		{
			$coloredToken = '<FONT COLOR="347C2C">' . $token . '</FONT>';
		}
		else 
		{
			$coloredToken = $token;
		}
		
        $string .= $coloredToken;
        $startIndex++;
    };
    return $string;
}
	
1;