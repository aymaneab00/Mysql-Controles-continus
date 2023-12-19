drop database if exists cc2_203;
create database cc2_203;
use cc2_203;

create table centre_sante(
	code_centre int auto_increment primary key
	);
    
create table medecin(code_medecin int auto_increment primary key, 
	nom_medecin varchar(50), 
    code_centre int , 
    constraint fk_medecin_centre foreign key(code_centre) references centre_sante(code_centre)
	);
    
create table ecole(
	code_ecole int auto_increment primary key, 
    nom_ecole varchar(50)
    );
    
create table enfant(
	matricule int auto_increment primary key, 
	nom_enfant varchar(50),
	code_medecin int , 
    code_ecole int , 
    constraint fk_enfant_medecin foreign key(code_medecin) references medecin(code_medecin),
    constraint fk_enfant_ecole foreign key(code_ecole) references ecole(code_ecole)
	);
 
create table vaccin(
	code_vaccin int auto_increment primary key 
		);
        
create table vacciner( 
	matricule int , 
	code_vaccin int,  
	constraint fk_vacciner_enfant foreign key(matricule) references enfant(matricule), 
    constraint fk_vacciner_vaccin foreign key(code_vaccin) references vaccin(code_vaccin)
    );
    


insert into centre_sante values (1),(2),(3);
insert into medecin values (1,'med1',1),(2,'med2',2),(3,'med3',3);
insert into ecole values (1,'ecole1'),(2,'ecole2'),(3,'ecole3');
insert into vaccin values (1),(2),(3);
insert into enfant values (1,'enf1',1,1),(2,'enf2',2,2),(3,'enf3',3,3);
insert into enfant values (4,'enf4',1,1);
insert into enfant values (5,'enf5',1,1);
insert into vacciner values (1,1),(1,2),(2,2),(2,3),(3,1),(3,3);

#1
create view eq1 as select * from enfant where code_ecole = 3 ;
select * from eq1;
#2 
select e.* , count(v.matricule) as nombre_vaccin from enfant e join vacciner v on v.matricule =e.matricule group by v.matricule order by nombre_vaccin desc limit 1  ;
#3
delimiter $$
create function eq3 (n int)
returns int 
deterministic 
begin
declare result int ;
select count(e.code_medecin)into result from medecin m join enfant e on e.code_medecin =m.code_medecin where m.code_medecin =n  group by m.code_medecin ;
return result;
end$$
delimiter ;
select eq3(2);

#select m.* , count(e.code_medecin) from medecin m join enfant e on e.code_medecin =m.code_medecin group by m.code_medecin;

#4
delimiter $$
create procedure eq4(n int)
begin
 select * from enfant where code_medecin = n;
end$$
delimiter ;
call eq4(2);
#5
delimiter $$
create procedure eq5 () 
begin
select * from medecin where code_centre = (select code_centre from medecin where code_medecin=3);
end$$
delimiter ;
#6
drop procedure if exists eq6;
delimiter $$
create procedure eq6()
begin
select m.* , count(e.code_medecin) as suivi from medecin m join enfant e on e.code_medecin = m.code_medecin group by m.code_medecin having suivi>4;
end$$

delimiter ;
#7 
alter table medecin add column nbEnf int default 0;
delimiter $$
create trigger t7 after insert on enfant for each row 
begin 
update medecin set nbEnf = nbEnf + 1 where code_medecin =new.code_medecin;
end$$
delimiter ;

#8
delimiter $$
create trigger t8 before delete on enfant for each row 
begin 
delete from vacciner where matricule = old.matricule;
end $$
delimiter ;
#9
drop trigger if exists eq9;
delimiter $$
create procedure eq9 ()
begin
declare flag boolean default  false ;
declare code_c int ;
declare  c1 cursor for select code_centre from centre_sante;
declare continue handler for not found set flag = true;
open c1 ;
b1:loop
fetch c1 into code_c ;
if flag then  leave b1; end if ;
begin
declare flag2 boolean default false;
declare code_med  int ;
declare nom_med varchar(50);
declare c2  cursor  for select code_medecin , nom_medecin from medecin ;
declare  continue handler for not found set flag=true;
open c2;
b2:loop 
fetch c2 into code_med,nom_med ;
if flag2 then leave b2 ; end if ;
insert into medecin values (code_med,nom_med,code_c,0);
end loop b2;
close c2;
end;
end loop b1;
close c1;

end $$
delimiter ;
call eq9();

select * from medecin ;
select * from medecin ;
#10 
alter table medecin add check (nbEnf<=30);
#11
alter table medecin add column salaire int default 10000 ;
drop procedure if exists eq10;
delimiter $$
create procedure eq10 ()
begin
declare c,s int ;
declare flag boolean default false;
declare c1 cursor for select code_medecin,salaire from medecin ;
declare continue handler for not found set flag = true;
open c1;
b1:loop
fetch c1 into c,s;
if flag then leave b1; end if;
if s <20000 then 
update medecin set salaire = salaire + (0.05*salaire) where code_medecin=c;
else update medecin set salaire =20000 where code_medecin=c;
end if ;
end loop b1;
close c1 ;
end$$
delimiter ;
call eq10(); #CORRECTE PROCEDURE CURSOR 
select * from medecin ;
update  medecin set salaire = 11111;