import { RegisterService } from '../../core/services/register/register.service';
import { AccountRegister } from '../../core/models/account-register.model';
import { Router } from "@angular/router";
import { Component, OnInit } from '@angular/core';
import {NgForm} from '@angular/forms';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.scss']
})
export class RegisterComponent implements OnInit {

  public account: AccountRegister = new AccountRegister();

  constructor(
    private registerService: RegisterService,
    private router: Router
  ) { }


  ngOnInit() {
    this.registerService.getAccounts().subscribe(data => console.log(data));
  }

  isValid(account: AccountRegister): boolean {
    if(account.username == null || account.password == null || account.repetePassword == null)
      return false;
    if (account.password != account.repetePassword)
      return false;
    return true;
  }
  
  register(): void {

    if (!this.isValid(this.account)) {
      console.log("Invalid data!");
    }
    else {
    this.registerService.postAccount(this.account).subscribe(data => {
        console.log(data);
      });
      this.router.navigate(['welcome']);
    }
  }

}
