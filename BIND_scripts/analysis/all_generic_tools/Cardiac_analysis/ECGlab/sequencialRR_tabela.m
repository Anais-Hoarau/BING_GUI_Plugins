function tabela=sequencialRR_tabela(indices)
% usage:


tabela=sprintf([...
      'Quadrants:\n',...
   	'  (+/+): %0.5g pts, %0.5g %%\n',...
      '  (-/+): %0.5g pts, %0.5g %%\n',...
      '  (-/-): %0.5g pts, %0.5g %%\n',...
      '  (+/-): %0.5g pts, %0.5g %%\n\n',...
      'Lines:\n',...
   	'  (+/o): %0.5g pts, %0.5g %%\n',...
      '  (o/+): %0.5g pts, %0.5g %%\n',...
      '  (-/o): %0.5g pts, %0.5g %%\n',...
      '  (o/-): %0.5g pts, %0.5g %%\n\n',...
      'Origin:\n',...
      '  (o/o): %0.5g pts, %0.5g %%\n\n',...
      'Total: %0.5g pts\n\n\n\n',...
      'Null Differences: %0.5g pts, %0.5g %%\n\n',...
      'Non-null Diffs.: %0.5g pts, %0.5g %%',...
	],...
   indices);
