function PlotUpdateTimeCompare()    
    x = 0:.1:8;
    y = sin(x);
    h = plot(x,y);
    set(h,'YDataSource','y')
    set(h,'XDataSource','x')
    y = sin(x.^3);

    tic
    for i=1:1000
        refreshdata(h,'caller');
    end
    toc 

    tic
    for i=1:100
        delete(h);
        h = plot(x,y);
    end
    toc     

    tic
    for i=1:100
        set(h,'XData',x,'YData',y);
    end
    toc 

end