require 'spec_helper'

describe "FinderSpec" do
  let :klass do
    Person
  end

  let :another_klass do
    Hobby
  end

  before :each do
    @bob      = FactoryGirl.create(:bob)
    @pharrell = FactoryGirl.create(:pharrell)
    @john     = FactoryGirl.create(:john)
  end

  describe "method_missing" do
    it "should not overwite default method missing" do
      expect(klass.find_by_id(1)).to eql(@bob)
      expect(klass.find_by_age_and_status(36, false)).to eql(@bob)
      expect(find_all(klass, :age => 36)).to eql([@bob, @john])
    end
  end

  describe "hsfind" do
    context "when defined by handlersocket" do
      before :each do
        klass.delete_all
      end

      context "for :first" do
        it "should call hsfind with method_missing" do
          expect(klass).not_to respond_to(:hsfind_by_id)
          expect(klass.hsfind_by_id(1)).to be_nil
        end
      end

      context "for :multi" do
        it "should call hsfind with method_missing" do
          expect(klass).not_to respond_to(:hsfind_multi_by_id)
          expect(klass.hsfind_multi_by_id(1)).to be_empty
        end
      end
    end

    context "when before definition by handlersocket" do
      context "for :first" do
        it "should raise error" do
          expect{
            klass.hsfind_by_name("Bob")
          }.to raise_error(ActiveRecordHandlerSocket::UnknownIndexError)
        end
      end

      context "for :multi" do
        it "should raise error" do
          expect{
            klass.hsfind_multi_by_name("Bob")
          }.to raise_error(ActiveRecordHandlerSocket::UnknownIndexError)
        end
      end
    end

    context "when records exist" do
      context "for :first" do
        it "should get one record by id" do
          person    = klass.find_by_id(1)
          hs_person = klass.hsfind_by_id(1)

          expect(hs_person).not_to be_nil
          expect(hs_person).to eql(person)
        end

        it "should get nil by unknown id" do
          person    = klass.find_by_id(9)
          hs_person = klass.hsfind_by_id(9)

          expect(person).to be_nil
          expect(hs_person).to be_nil
        end
      end

      context "for :multi" do
        it "should get one record by id" do
          person    = find_all(klass, :id => 1)
          hs_person = klass.hsfind_multi_by_id(1)

          expect(hs_person.size).to eql(1)
          expect(hs_person).to eql(person)
        end

        it "should get some records by ids" do
          people    = find_all(klass, :id => [1, 2])
          hs_people = klass.hsfind_multi_by_id(1, 2)

          expect(hs_people).to eql(people)
        end

        it "should get empty array by unknown id" do
          people    = find_all(klass, :id => 9)
          hs_people = klass.hsfind_multi_by_id(9)

          expect(people).to be_empty
          expect(hs_people).to be_empty
        end
      end
    end

    describe "finder with options" do
      context "for :single" do
        context "with operator option" do
          it "should find greater value record" do
            hs_person = klass.hsfind_by_id(0, :operator => ">")

            expect(hs_person).to be_kind_of(klass)

            hs_person = klass.hsfind_by_id(3, :operator => ">")

            expect(hs_person).to be_nil
          end

          it "should find less value record" do
            person    = klass.find_by_id(2)
            hs_person = klass.hsfind_by_id(3, :operator => "<")

            expect(hs_person).not_to be_nil
            expect(hs_person).to eql(person)

            hs_person = klass.hsfind_by_id(0, :operator => "<")

            expect(hs_person).to be_nil
          end
        end

        context "with each_limit option" do
          it "should ignore each_limit option" do
            person    = klass.find_by_id(2)
            hs_person = klass.hsfind_by_id(3, :operator => "<", :each_limit => 10)

            expect(hs_person).not_to be_nil
            expect(hs_person).to eql(person)
            expect(hs_person).not_to be_kind_of(Array)
          end
        end
      end

      context "for :multi" do
        context "with operator option" do
          it "should find greater value record" do
            hs_people = klass.hsfind_multi_by_id(0, :operator => ">")

            expect(hs_people.size).to  eql(1)
            expect(hs_people.first).to be_kind_of(klass)

            hs_people = klass.hsfind_multi_by_id(3, :operator => ">")

            expect(hs_people).to be_empty
          end

          it "should find less value record" do
            people    = find_all(klass, :id => 2)
            hs_people = klass.hsfind_multi_by_id(3, :operator => "<")

            expect(hs_people).to eql(people)

            hs_people = klass.hsfind_multi_by_id(0, :operator => "<")

            expect(hs_people).to be_empty
          end
        end

        context "with each_limit option" do
          it "should find greater value records" do
            people    = find_all(klass, :id => [1, 2, 3])
            hs_people = klass.hsfind_multi_by_id(0, :operator => ">", :each_limit => 10)

            expect(hs_people).to eql(people)
          end
        end

        context "with discarded limit option" do
          it "should ignore option" do
            hs_people = klass.hsfind_multi_by_id(0, :operator => ">", :limit => 10)

            expect(hs_people).to eql([@bob])
          end
        end
      end
    end

    describe "with multi column index" do
      context "for :single" do
        context "when use 1st sequence column" do
          it "should find record" do
            person    = klass.find_by_age(36)
            hs_person = klass.hsfind_by_age_and_status(36)

            expect(hs_person).not_to be_nil
            expect(hs_person).to eql(person)
          end
        end

        context "when use all sequence columns" do
          it "should find record" do
            person    = klass.find_by_age_and_status(36, false)
            # XXX: Cannot use `true/false`
            hs_person = klass.hsfind_by_age_and_status(36, 0)

            expect(hs_person).not_to be_nil
            expect(hs_person).to eql(person)
          end
        end

        context "when use not 1st sequence column" do
          it "should not find record" do
            # XXX: Cannot use `true/false`
            hs_person = klass.hsfind_by_age_and_status(0)

            expect(hs_person).to be_nil
          end
        end
      end

      context "for :multi" do
        context "when use 1st sequence column" do
          it "should find records" do
            people    = find_all(klass, :age => 36)
            hs_people = klass.hsfind_multi_by_age_and_status(36, :each_limit => 10)

            expect(hs_people.size).to eql(2)
            expect(hs_people).to eql(people)

            hs_people = klass.hsfind_multi_by_age_and_status([36], :each_limit => 10)

            expect(hs_people.size).to eql(2)
            expect(hs_people).to eql(people)
          end
        end

        context "when use all sequence columns" do
          it "should find records" do
            people    = find_all(klass, :age => 36, :status => false)
            # XXX: Cannot use `true/false`
            hs_people = klass.hsfind_multi_by_age_and_status([36, 0], :each_limit => 10)

            expect(hs_people.size).to eql(1)
            expect(hs_people).to eql(people)
          end

          it "should find records by multi condition" do
            people    = [find_all(klass, :age => 36, :status => false), find_all(klass, :age => 36, :status => true)].flatten
            # XXX: Cannot use `true/false`
            hs_people = klass.hsfind_multi_by_age_and_status([36, 0], [36, 1], :each_limit => 10)

            expect(hs_people.size).to eql(2)
            expect(hs_people).to eql(people)
          end
        end

        context "when use not 1st sequence column" do
          it "should find records" do
            # XXX: Cannot use `true/false`
            hs_people = klass.hsfind_multi_by_age_and_status([0], :each_limit => 10)

            expect(hs_people).to be_empty
          end
        end
      end
    end

    describe "with active_record callbacks" do
      context "for :single" do
        it "should work after_find callback" do
          hs_person = klass.hsfind_by_id(1)
          expect(hs_person.born_year).to eql(Time.now.year - hs_person.age)
          expect(hs_person.instance_variable_get(:@born_year)).to eql(hs_person.born_year)
        end

        it "should work after_initialize callback" do
          hs_person = klass.hsfind_by_id(1)
          expect(hs_person.family_name).to eql(hs_person.name.split(" ").last)
          expect(hs_person.instance_variable_get(:@family_name)).to eql(hs_person.family_name)
        end
      end

      context "for :multi" do
        it "should work after_find callback" do
          hs_people = klass.hsfind_multi_by_id(1, 2)

          hs_person = hs_people[0]
          expect(hs_person.born_year).to eql(Time.now.year - hs_person.age)
          expect(hs_person.instance_variable_get(:@born_year)).to eql(hs_person.born_year)

          hs_person = hs_people[1]
          expect(hs_person.born_year).to eql(Time.now.year - hs_person.age)
          expect(hs_person.instance_variable_get(:@born_year)).to eql(hs_person.born_year)
        end

        it "should work after_initialize callback" do
          hs_people = klass.hsfind_multi_by_id(1, 2)

          hs_person = hs_people[0]
          expect(hs_person.family_name).to eql(hs_person.name.split(" ").last)
          expect(hs_person.instance_variable_get(:@family_name)).to eql(hs_person.family_name)

          hs_person = hs_people[1]
          expect(hs_person.family_name).to eql(hs_person.name.split(" ").last)
          expect(hs_person.instance_variable_get(:@family_name)).to eql(hs_person.family_name)
        end
      end
    end

    describe "with connection" do
      before :each do
        ActiveRecord::Base.__send__(:hs_reconnect!)
      end

      it "should open index before find" do
        expect{
          klass.hsfind_by_id(1)
        }.not_to raise_error
        expect(ActiveRecord::Base.__send__(:hs_indexes)[klass.__send__(:hs_index_key, "id")][:opened]).to be
      end
    end
  end

  describe "hs_instantiate (after hsfind)" do
    context "when valid result" do
      it "should return single record" do
        result = klass.__send__(:hs_instantiate, klass.__send__(:hs_index_key, "id"), [0, [["1", "MySQL", "19", "1"]]])

        expect(result.size).to eql(1)

        record = result.first
        expect(record.id).to     eql(1)
        expect(record.name).to   eql("MySQL")
        expect(record.age).to    eql(19)
        expect(record.status).to be
      end

      it "should return multi record" do
        result = klass.__send__(:hs_instantiate, klass.__send__(:hs_index_key, "id"), [0, [["1", "MySQL", "19", "1"], ["2", "%#123", "55", "0"]]])

        expect(result.size).to eql(2)

        record = result.first
        expect(record.id).to     eql(1)
        expect(record.name).to   eql("MySQL")
        expect(record.age).to    eql(19)
        expect(record.status).to be

        record = result.last
        expect(record.id).to         eql(2)
        expect(record.name).to       eql("%#123")
        expect(record.age).to        eql(55)
        expect(record.status).not_to be
      end
    end

    context "when invalid result" do
      it "should raise error" do
        expect{
          klass.__send__(:hs_instantiate, klass.__send__(:hs_index_key, "id"), [2, "kpnum"])
        }.to raise_error(ArgumentError)
      end
    end

    context "when connection error" do
      before :each do
        klass.hsfind_by_id(1)
        another_klass.hsfind_by_id(1)
      end

      it "should raise error and mark opened_index closed" do
        expect(klass.__send__(:hs_indexes)[klass.__send__(:hs_index_key, "id")][:opened]).to be
        expect(another_klass.__send__(:hs_indexes)[another_klass.__send__(:hs_index_key, "id")][:opened]).to be

        expect{
          klass.__send__(:hs_instantiate, klass.__send__(:hs_index_key, "id"), [-1, "connection lost"])
        }.to raise_error(ActiveRecordHandlerSocket::ConnectionLost)

        expect(klass.__send__(:hs_indexes)[klass.__send__(:hs_index_key, "id")][:opened]).not_to be
        expect(another_klass.__send__(:hs_indexes)[another_klass.__send__(:hs_index_key, "id")][:opened]).not_to be
      end
    end
  end
end
