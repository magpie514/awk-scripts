function _update(){
	for(i=52; i<=949; i++){
		d=m[i-1]+m[i+1]+m[i-51]+m[i-50]+m[i-49]+m[i+49]+m[i+50]+m[i+51];
		n[i]=m[i];
		if(m[i]==0 && d==3) n[i]=1;
		else if(m[i]==1 && d<2) n[i]=0;
		else if(m[i]==1 && d>3) n[i]=0;
	}
	printf("\033[1;1H");   # Home cursor
	for(i=1;i<=1000;i++) {
		if(n[i]) printf("█"); else printf("░");
		m[i]=n[i];
		if(!(i%50)) printf("\n");
	}
}

BEGIN {
	c=220; d=619; i=10000;
	srand(seed)
	printf("\033[2J");      # Clear screen
	while(i--) m[i]=0;
	while(d--) m[int(rand()*1000)]=1;
}

{
	_update()
}