import { AccountRegisterGet } from '../../models/account-register-get.model';
import { AccountRegister } from '../../models/account-register.model';
import { StudentDetails } from '../../models/student-details.model';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { HttpClient, HttpHeaders, HttpHeaderResponse } from '@angular/common/http';

import { environment } from "../../../../environments/environment";

@Injectable()
export class RegisterService {

  private registerUrl = `${environment.apiUrl}/accounts`
  constructor(private http: HttpClient) { }


  public getAccounts() : Observable<AccountRegisterGet>
  {
    return this.http.get<AccountRegisterGet>(this.registerUrl);
  }

  public postAccount(account: AccountRegister): Observable<AccountRegister> {
    return this.http.post<AccountRegister>(this.registerUrl, account);
  }
}
