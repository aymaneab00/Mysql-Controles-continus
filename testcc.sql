drop database if exists cc2_201;
create database cc2_201;
use cc2_201;

create table chauffeur(
	code_ch varchar(10) primary key,
    nom_ch varchar(30),
    pre_ch varchar(30),
    date_ch date,
    ad_ch varchar(80),
    cp_ch varchar(5),
    ville_ch varchar(40),
    tel_ch varchar(15)
	);
    
       
create table type(
	type  varchar(10) primary key, 
    lib_type varchar(30)
    );
   
   create table hangar( 
	num_hg varchar(10) primary key , 
	nb_places int,  
    garde boolean);
  
  
create table vehicule(
	immat  varchar(10) primary key, 
	marque varchar(5), 
    ref varchar(5), 
    puis int,
    poids float,
    equip varchar(30),
    cout_km float,
    type varchar(10),
    num_hg varchar(10),
    constraint fk_vehicule_type foreign key(type) references type(type),
    constraint fk_vehicule_hangar foreign key(num_hg) references hangar(num_hg)

	);
 
      
create table permis(
	code_per  varchar(5) primary key, 
    lib_per varchar(30)
    );
 
   
create table obtenir( 
	code_per varchar(5) , 
	code_ch varchar(10),  
    date_ob date,
	constraint fk_obtenir_permis foreign key(code_per) references permis(code_per), 
    constraint fk_obtenir_chauffeur foreign key(code_ch) references chauffeur(code_ch)
    );
    
create table date_util(
	date_util date primary key 
		);
   
   create table utiliser( 
	date_util date , 
    code_ch varchar(10),
    immat varchar(10),
	km_deb int,
    km_fin int,
	constraint fk_utiliser_date_util foreign key(date_util) references date_util(date_util), 
	constraint fk_utiliser_chauffeur foreign key(code_ch) references chauffeur(code_ch), 
    constraint fk_utiliser_vehicule foreign key(immat) references vehicule(immat)
    );
    
    
    



insert into permis values (1,'A'),(2,'B'),(3,'C');
insert into hangar values (1,100,true),(2,50,true),(3,200,false);
insert into type values (1,'citadine'),(2,'utilitaire'),(3,'camion');
insert into date_util values ('2023-12-11'),('2023-12-12'),('2023-12-13');
insert into chauffeur values (1,'ch1','ch1','2022-01-01','ad1',20000,'tetouan','06212154');
insert into chauffeur values (2,'ch2','ch2','2021-01-01','ad2',30000,'martil','06212155');
insert into chauffeur values (3,'ch3','ch3','2020-01-01','ad3',40000,'tanger','06212156');

insert into vehicule values ('B1','pg','a1',1,2,'a1',15421,1,1);
insert into vehicule values ('B2','rn','a2',1,2,'a2',80000,2,2);
insert into vehicule values ('B3','mr','a3',1,2,'a3',500,3,3);


insert into obtenir values (1,1,'2019-11-15'),(2,2,'2019-11-19'),(3,3,'2019-11-16');

insert into utiliser values ('2023-12-11',1,'B1',1000,2000),('2023-12-12',1,'B2',3000,4000),('2023-12-13',1,'B3',5000,6000);


#1-
create view  v1 as ( select c.* from chauffeur c join obtenir o on c.code_ch =o.code_ch join permis p on o.code_per = p.code_per where p.lib_per="B");
select * from v1;
#2 -
select c.*, count(o.code_ch)as nombre_permis from chauffeur c join obtenir o on c.code_ch = o.code_ch 
group by c.code_ch order by nombre_permis;

#3
drop function  if exists ex3;
delimiter $$
create function ex3(n int )
returns int
deterministic 
begin
declare resultat int ;
select count(u.code_ch) into resultat from chauffeur c join utiliser u on u.code_ch where u.code_ch = n ;
return resultat;
end $$
delimiter ;
select ex3(4);
#4	
delimiter $$
create procedure eq4(n int )
begin
select v.immat , v.marque from vehicule v join utiliser u on v.immat=u.immat where u.code_ch=n;
end $$
delimiter ; 
call eq4(3);

#5
delimiter $$
create procedure ex5()
begin
select v.immat , v.marque from vehicule v where v.type= (select type from vehicule where immat="B3");
end $$
delimiter ;
call ex5();
select * from type;
select * from vehicule;
#6
delimiter $$
create procedure ex6 ()
begin
create view ex6v as select code_ch , sum(km_fin - km_deb) as kilo from utiliser group by code_ch having kilo>20000 ;
select count(*) from ex6v;
end$$
delimiter ;
call ex6();

#7 
alter table chauffeur add column nbKm int ;
drop trigger if exists  t7;
delimiter $$
create trigger t7 after  insert on utiliser for each row 
begin
update chauffeur set nbKm=nbKm+(new.km_fin - new.km_deb) where code_ch = new.code_ch;
end$$
delimiter ;

select * from utiliser;
select * from chauffeur;
alter table chauffeur modify nbKm int default 0;
insert into utiliser values ('2023-12-11',3,'B1',1000,2000);

#8
drop trigger if exists  t8;
delimiter $$
create trigger t8 before  delete on vehicule for each row 
begin
delete  from utiliser u where immat = old.immat;
end$$
delimiter ;

#9
drop procedure if exists ex9;
delimiter $$
create procedure ex9()
begin
declare code_chauff int ;
declare flag boolean default false;
declare c1 cursor for select code_ch from chauffeur;
declare continue handler for not found set flag =true;
open c1;
b1:loop
fetch c1 into code_chauff ;
if flag then
 leave b1 ;
 end if;
 begin
 declare per int;
 declare flag2 boolean default false;
 declare c2 cursor  for select code_per from permis;
 declare continue handler for not found set flag2=true;
 open c2;
 b2:loop 
 fetch c2 into per ;
 if flag2 then 
 leave b2; end if;
 insert into obtenir values(per,code_chauff,current_date());
 end loop b2;
 close c2;
end;
 end loop b1;
    close c1;
 end;
end$$
delimiter ;
#10
select * from utiliser;
alter table utiliser  add constraint check ( (km_fin - km_deb ) <50000 );
#11
alter table chauffeur add column salaire int default 10000;
select * from chauffeur;
drop procedure if exists ex11;
delimiter $$
create procedure ex11()
begin 
declare c,s,km int ;
declare flag boolean default  false;
declare c1 cursor for select code_ch,salaire,nbKm from chauffeur ;
declare continue handler for sqlexception set flag =true;
open c1;
b1:loop
fetch c1 into c,s,km;
if flag then leave b1 ;
end if;
if km %1000=0 then 
#update table  chauffeur set salaire = salaire + (salaire * 5%);
set s = s+ floor(km/1000)*(s*0.05);
end if ;

if s >20000 then  set s = 20000 ;
end if ;
 update   chauffeur set salaire=s where code_ch = c;

end loop b1;
close c1;
end $$
delimiter ;
#12
create role "chauffeur";
#13
create user "chauffeur1"@"localhost" identified by "1234";

grant chauffeur to "chauffeur1"@"localhost";
#14
grant "chauffeur" to "chauffeur1"@"localhost";
revoke "chauffeur" from "chauffeur1"@"localhost";

show grants for chauffeur1@localhost;
show grants for chauffeur;
create role "ch"@"localhost";
grant select on cc2_201.vehicule to "ch"@"localhost";
grant "ch"@"localhost"to "chauffeur1"@"localhost";
show databases;
#15