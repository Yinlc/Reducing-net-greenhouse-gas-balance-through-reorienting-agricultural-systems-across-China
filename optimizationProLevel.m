function [fvalPro,ConversionPro]=optimizationProLevel(input)
     data_all=csvread(input,1); % 
    if isempty(find(isnan(data_all), 1))
        cropland_total_area=sum(data_all(:,3));
        sow_area=data_all(:,3);
        
        ngb_all=sum(data_all(:,3).*data_all(:,14));% Total NGB
        GHG_all=sum(data_all(:,3).*data_all(:,7));% total GHG
        money_all=sum(data_all(:,3).*data_all(:,9));% Total economic
        irrigation_all=sum(data_all(:,3).*data_all(:,10));% Total irrigation
        stableFood_all=sum(data_all(:,15).*data_all(:,3)); %Total grain energy
        kal_sugar_all=sum(data_all(:,17).*data_all(:,3));% total sugar
        kal_oil_all=sum(data_all(:,16).*data_all(:,3));% Total oil
        cotton_area_all=sum(data_all(data_all(:,2)==15,3).*data_all(data_all(:,2)==15,4));% cotton
        tobacco_area_all=sum(data_all(data_all(:,2)==14,3).*data_all(data_all(:,2)==14,4));% tobacco
        
        GHG_u=data_all(:,7);% unit CO2
        ir_u=data_all(:,10); % unit irrigation
        money_u=data_all(:,9);% unit economic
        stable_u=data_all(:,15); % unit food energy
        ngb_u=data_all(:,14);% NGB
        sow_upper_sum=data_all(:,18);% 
        kal_sugar=data_all(:,17);
        kal_oil=data_all(:,16);
        area_cotton=zeros(size(data_all,1),1);
        area_cotton(data_all(:,2)==15)=1;
        area_cotton=area_cotton.*data_all(:,4);
        
        area_tobacco=zeros(size(data_all,1),1);
        area_tobacco(data_all(:,2)==14)=1; % 
        area_tobacco=area_tobacco.*data_all(:,4);
        
        if cropland_total_area>0
            unique_city=unique(data_all(:,1));
            
            b1sum=[];
            sow_city_sum=[]; 
            for k=1:length(unique_city)
                city_k=unique_city(k);
                sy_city=find(data_all(:,1)==city_k);
                b1=zeros(length(data_all(:,1)),1)';
                b1(sy_city)=1;
                b1sum=[b1sum;b1];
                sow_city=data_all(sy_city,19);
                sow_city=sow_city(1);
                sow_city_sum=[sow_city_sum;sow_city];
            end
            
            sy_sow=find(sow_area>0);
            if length(sy_sow)>=2
                f=ngb_u;
                intcon=length(ngb_u); 
                fitnessfcn = @(x)(sum(ngb_u.*x)); % 
                nvars =length(ngb_u); 
                lb = zeros(length(ngb_u),1); %
                ub=sow_upper_sum;
                Aeq=b1sum;
                Beq=sow_city_sum;
                A=[-1.*kal_oil';-1.*area_cotton';-1.*kal_sugar';-1.*stable_u';-1.*money_u';area_tobacco';GHG_u';ir_u';ngb_u'];
                b=[-kal_oil_all;-cotton_area_all;-kal_sugar_all;-stableFood_all;-money_all;tobacco_area_all;GHG_all;irrigation_all;ngb_all];
                x0=sow_area;
                [x,~,exitflag,~]=intlinprog(f,intcon,A,b,Aeq,Beq,lb,ub,x0); %
                 if exitflag==1
                    cz_ini=x-sow_area; %
                    syzsum=[];
                    for k=1:length(unique_city)
                        city_k=unique_city(k);
                        sy_city=find(data_all(:,1)==city_k);
                        cz_ini_city=cz_ini(sy_city); % 
                        sow_area_city=data_all(sy_city,3);
                        syz=[length(find(cz_ini_city<0)),length(find(sow_area_city>0))];
                        if syz(1)>0 && syz(2)>0
                             syzsum=[syzsum;syz];
                        end
                    end
                    syzsum_varibalesum=syzsum(:,2).* syzsum(:,1);
                    total_varibalesum=sum(syzsum_varibalesum); % ??????????????
                    
                    location_sum=[];
                    for kk=1:length(syzsum_varibalesum)
                        wei2=sum(syzsum_varibalesum(1:kk));
                        wei1=wei2-syzsum_varibalesum(kk)+1;
                        wei=[wei1,wei2];
                        location_sum=[location_sum;wei];
                    end
                    
                    Aeq_total=[];
                    beq_total=[];
                    A_total=zeros(9,total_varibalesum);
                    up_total=[];
                    f_total=[];
                    x0_total=[];
                    area_total_max_3_total=[];% 
                    area_xs_sum_total_sum=[];
                    location=1;
                    crop_xl_2_total=[];
                    for k=1:length(unique_city)
                        city_k=unique_city(k);
                        sy_city=find(data_all(:,1)==city_k);
                        cz_ini_city=cz_ini(sy_city);
                        crop_xl_sum=[];
                        for kk=1:17
                              crop_xl=[zeros(17,1)+kk,[1:17]'];
                              crop_xl_sum=[crop_xl_sum;crop_xl];
                        end
                     %% 
                        sow_area=data_all(sy_city,3);
                        GHG_u=data_all(sy_city,7);% unit CO2
                        ir_u=data_all(sy_city,10); % unit irrigation
                        money_u=data_all(sy_city,9);% unit economic
                        stable_u=data_all(sy_city,15); % unit food energy
                        ngb_u=data_all(sy_city,14);% NGB
                        sow_upper_sum=data_all(sy_city,18);% 
                        kal_sugar=data_all(sy_city,17);
                        kal_oil=data_all(sy_city,16);
                        yield_cotton=area_cotton(sy_city);
                        yield_tobacco=area_tobacco(sy_city);
                    %% 
                        cz_kal_oil_sum=[];
                        for kk=1:17 % 17 cropping systems
                            kal_oil_1=kal_oil(kk);
                            for kkk=1:17
                                kal_oil_2=kal_oil(kkk);
                                cz_kal_oil=kal_oil_2-kal_oil_1;
                                cz_kal_oil_sum=[cz_kal_oil_sum;cz_kal_oil];
                            end
                        end
                        % 
                    cz_kal_sugar_sum=[];
                    for kk=1:17
                        kal_sugar_1=kal_sugar(kk);
                        for kkk=1:17
                            kal_sugar_2=kal_sugar(kkk);
                            cz_kal_sugar=kal_sugar_2-kal_sugar_1;
                            cz_kal_sugar_sum=[cz_kal_sugar_sum;cz_kal_sugar];
                        end
                    end
                    % 
                     cz_pro_xs_sum=[];
                    for kk=1:17
                        production_xs_1=stable_u(kk);
                        for kkk=1:17
                            production_xs_2=stable_u(kkk);
                            cz_production_xs=production_xs_2-production_xs_1;
                            cz_pro_xs_sum=[cz_pro_xs_sum;cz_production_xs];
                        end
                    end
                    % 
                    cz_ir_u_sum=[];
                    for kk=1:17
                        ir_u_1=ir_u(kk);
                        for kkk=1:17
                            ir_u_2=ir_u(kkk);
                            cz_ir_u=ir_u_2-ir_u_1;
                            cz_ir_u_sum=[cz_ir_u_sum;cz_ir_u];
                        end
                    end
                    % 
                     cz_money_u_sum=[];
                    for kk=1:17
                        money_u_1=money_u(kk);
                        for kkk=1:17
                            money_u_2=money_u(kkk);
                            cz_money_u=money_u_2-money_u_1;
                            cz_money_u_sum=[cz_money_u_sum;cz_money_u];
                        end
                    end
                    % 
                    cz_ngb_u_sum=[];
                    for kk=1:17
                        ngb_u_1=ngb_u(kk);
                        for kkk=1:17
                            ngb_u_2=ngb_u(kkk);
                            cz_ngb_u=ngb_u_2-ngb_u_1;
                            cz_ngb_u_sum=[cz_ngb_u_sum;cz_ngb_u];
                        end
                    end
                    % 
                    cz_GHG_u_sum=[];
                    for kk=1:17
                        GHG_u_1=GHG_u(kk);
                        for kkk=1:17
                            GHG_u_2=GHG_u(kkk);
                            cz_GHG_u=GHG_u_2-GHG_u_1;
                            cz_GHG_u_sum=[cz_GHG_u_sum;cz_GHG_u];
                        end
                    end
                    % tobacco
                    cz_yield_tobacco_sum=[];
                    for kk=1:17
                        yield_tobacco_1=yield_tobacco(kk);
                        for kkk=1:17
                            yield_tobacco_2=yield_tobacco(kkk);
                            cz_yield_tobacco=yield_tobacco_2-yield_tobacco_1;
                            cz_yield_tobacco_sum=[cz_yield_tobacco_sum;cz_yield_tobacco];
                        end
                    end
                    % cotton
                    cz_yield_cotton_sum=[];
                    for kk=1:17
                        yield_cotton_1=yield_cotton(kk);
                        for kkk=1:17
                            yield_cotton_2=yield_cotton(kkk);
                            cz_yield_cotton=yield_cotton_2-yield_cotton_1;
                            cz_yield_cotton_sum=[cz_yield_cotton_sum;cz_yield_cotton];
                        end
                    end
                   area_xs_sum_total=[]; % 
                   for kkk=1:17
                       area_xs_sum=[];
                       for kk=1:17
                            area_xs=zeros(17,1)';
                            area_xs(kkk)=1;
                            area_xs_sum=[area_xs_sum,area_xs];
                       end
                       area_xs_sum_total=[area_xs_sum_total;area_xs_sum];
                   end
                   area_total_max=sow_area.*20; %
                   area_total_max(area_total_max>sum(sow_area))=sum(sow_area);
                   
                      sy_decrease=find(cz_ini_city<0);%
                      sy_sow=find(sow_area>0); % 
                      if ~isempty(sy_decrease)
                            vsum1=[];
                            for kk=1:length(sy_decrease)
                                for kkk=1:length(sy_sow)
                                     v=[sy_decrease(kk) sy_sow(kkk)];
                                     vsum1=[vsum1;v];
                                end
                            end
                            syzsum1=[]; % 
                            for kk=1:length(vsum1)
                                syz=find( crop_xl_sum(:,1)==vsum1(kk,1) &  crop_xl_sum(:,2)==vsum1(kk,2));
                                syzsum1=[syzsum1;syz];
                            end
                            crop_xl_1=crop_xl_sum(syzsum1,:);
                            %crop_xl_1_sum=[crop_xl_1_sum;crop_xl_1];
                            crop_xl_2=[zeros(size(crop_xl_1,1),1)+city_k,crop_xl_1];
                            crop_xl_2_total=[crop_xl_2_total;crop_xl_2];
                            cz_ngb_u_sum=cz_ngb_u_sum(syzsum1); 
                            cz_kal_oil_sum=cz_kal_oil_sum(syzsum1)./10^4;
                            cz_yield_cotton_sum=cz_yield_cotton_sum(syzsum1);
                            cz_kal_sugar_sum=cz_kal_sugar_sum(syzsum1)./10^4;
                            cz_pro_xs_sum=cz_pro_xs_sum(syzsum1)./10^4;
                            cz_money_u_sum=cz_money_u_sum(syzsum1);
                            cz_yield_tobacco_sum=cz_yield_tobacco_sum(syzsum1);
                            cz_GHG_u_sum=cz_GHG_u_sum(syzsum1);
                            cz_ir_u_sum=cz_ir_u_sum(syzsum1);
                            
                            sy_inc=find(cz_ini_city>=0 & sow_area>0);% 
                            area_xs_sum_total_1=area_xs_sum_total(sy_decrease,syzsum1);
                            area_total_max_1=area_total_max(sy_decrease);
                            area_total_max_2=area_total_max(sy_inc).*19/20;
                             sy_inc_sysum=[];
                            for kk=1:length(sy_inc)
                                sy_inc_sy=find(sy_sow==sy_inc(kk));
                                sy_inc_sysum=[sy_inc_sysum;sy_inc_sy];
                            end
                            
                            sl=length(syzsum1)./length(sy_decrease);
                            d1zall=[];
                            for kkk=1:length(sy_inc)
                                d1z=[];
                                for kk=1:length(sy_decrease)
                                     d1=zeros(1,sl);
                                     d1(sy_inc_sysum(kkk))=1;
                                     d1z=[d1z,d1];
                                end
                                d1zall=[d1zall;d1z];
                            end
                            area_xs_sum_total_2=d1zall;
                            lb = zeros(length(vsum1),1); % ????
                            
                            ub=[];
                            A1sum=[];
                            for kk=1:length(sy_decrease)
                                d1=zeros(1,length(syzsum1));
                                d1((kk-1)*sl+1:kk*sl)=1;
                                A1sum=[A1sum;d1];
                                ub1=zeros(sl,1)+sow_area(sy_decrease(kk));
                                ub=[ub;ub1];
                            end
                            Aeq1=A1sum;
                            Aeq2=zeros(size(Aeq1,1),total_varibalesum);
                            Aeq2(:,location_sum(location,1):location_sum(location,2))=Aeq1;
                            beq1= sow_area(sy_decrease);
                            
                            area_xs_sum_total=[area_xs_sum_total_1;area_xs_sum_total_2]; % ????????????
                            area_xs_sum_total_all=zeros(size(area_xs_sum_total,1),total_varibalesum);
                            area_xs_sum_total_all(:,location_sum(location,1):location_sum(location,2))=area_xs_sum_total;
                            area_xs_sum_total_sum=[area_xs_sum_total_sum; area_xs_sum_total_all];
                            
                            area_total_max_3=[area_total_max_1;area_total_max_2]; % ????????????????????
                            A1=[-1.* cz_kal_oil_sum';-1.*cz_yield_cotton_sum';-1.*cz_kal_sugar_sum';-1.*cz_pro_xs_sum';-1.*cz_money_u_sum';cz_yield_tobacco_sum';cz_GHG_u_sum';cz_ir_u_sum';cz_ngb_u_sum';];
                            x0=ub;
                            syyy=find(vsum1(:,1)~=vsum1(:,2));
                            x0(syyy)=0;
                            x0(crop_xl_1(:,1)==15 & crop_xl_1(:,2)~=15)=0;
                            x0(crop_xl_1(:,1)~=14 & crop_xl_1(:,2)==14)=0;
                            f=cz_ngb_u_sum;
                            up_total=[up_total;ub];
                            x0_total=[x0_total;x0];
                            area_total_max_3_total=[area_total_max_3_total;area_total_max_3];
                            f_total=[f_total;f];
                            beq_total=[beq_total;beq1];
                            A_total(:,location_sum(location,1):location_sum(location,2))=A1;
                            Aeq_total=[Aeq_total;Aeq2];
                            location=location+1;
                      end
                    end
                    A_total=[A_total;area_xs_sum_total_sum];
                    b_total=[zeros(9,1);area_total_max_3_total];
                    lb=zeros(length(up_total),1);
                    intcon_total=length(up_total);
                    [x1,fvalPro,exitflag1,~]=intlinprog(f_total,intcon_total,A_total,b_total,Aeq_total,beq_total,lb,up_total,x0_total); %
                    if exitflag1==1
                        ConversionPro=[crop_xl_2_total,x1];
                    end
                end
            end
        end
    end
end